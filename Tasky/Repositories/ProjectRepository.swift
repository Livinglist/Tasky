//
//  ProjectRepository.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import Foundation

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class ProjectRepository: ObservableObject {
    private let path: String = "projects"
    private let testUserId: String = "testUserId"
    private let store = Firestore.firestore()
    
    @Published var projects: [Project] = []
    
    var userId = ""
    
    private let authenticationService:AuthService
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(authService: AuthService) {
        //        authenticationService.$user
        //            .compactMap { user in
        //                if user?.uid.isEmpty ?? true {
        //                    return self.testUserId
        //                }else{
        //                    return user?.uid
        //                }
        //            }
        //            .assign(to: \.userId, on: self)
        //            .store(in: &cancellables)
        self.authenticationService = authService
        
        
        authenticationService.$user
            .compactMap { user in
                if user?.uid.isEmpty ?? true {
                    return self.testUserId
                }else{
                    return user?.uid
                }
            }.receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                self.userId = $0
            })
            .store(in: &cancellables)
        
        authenticationService.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.get()
            }
            .store(in: &cancellables)
    }
    
    func fetchProjectsWithoutTasks(){
        store.collection("projects").whereField("managerId", isEqualTo: userId).addSnapshotListener{ querySnapshot, error in
            if let error = error {
                print("Error getting projects: \(error.localizedDescription)")
                return
            }
            
            self.projects = querySnapshot?.documents.compactMap { document in
                var project = try? document.data(as: Project.self)
                var tasks: [Task] = []
                
                self.store.collection("projects").document(project!.id!).collection("tasks").getDocuments { snapshots, err in
                    if let err = err {
                        print("Error getting projects: \(err.localizedDescription)")
                        return
                    }
                    
                    tasks = snapshots?.documents.compactMap { doc in
                        let task = try? doc.data(as: Task.self)
                        return task
                    } ?? []
                    
                    project?.tasks = tasks
                    
                    //print("the project tasks are \(project?.tasks)")
                    
                    self.projects.removeAll {
                        if project == $0 {
                            return true
                        }
                        return false
                    }
                    self.projects.append(project!)
                }
                
                return project
            } ?? []
            
        }
    }
    
    func get() {
        store.collection("projects").whereField("managerId", isEqualTo: userId).addSnapshotListener{ querySnapshot, error in
            if let error = error {
                print("Error getting projects: \(error.localizedDescription)")
                return
            }
            
            querySnapshot?.documents.compactMap { document in
                var project = try? document.data(as: Project.self)
                var tasks: [Task] = []
                
                self.store.collection("projects").document(project!.id!).collection("tasks").getDocuments { snapshots, err in
                    if let err = err {
                        print("Error getting projects: \(err.localizedDescription)")
                        return
                    }
                    
                    tasks = snapshots?.documents.compactMap { doc in
                        let task = try? doc.data(as: Task.self)
                        return task
                    } ?? []
                    
                    project?.tasks = tasks
                    
                    self.projects.removeAll {
                        if project == $0 {
                            return true
                        }
                        return false
                    }
                    self.projects.append(project!)
                }
                
                return project
            } ?? []
        }
        
        store.collection("projects").whereField("collaboratorIds", arrayContains: userId).addSnapshotListener{ querySnapshot, error in
            if let error = error {
                print("Error getting projects: \(error.localizedDescription)")
                return
            }
            
            querySnapshot?.documents.compactMap { document in
                var project = try? document.data(as: Project.self)
                var tasks: [Task] = []
                
                self.store.collection("projects").document(project!.id!).collection("tasks").getDocuments { snapshots, err in
                    if let err = err {
                        print("Error getting projects: \(err.localizedDescription)")
                        return
                    }
                    
                    tasks = snapshots?.documents.compactMap { doc in
                        let task = try? doc.data(as: Task.self)
                        return task
                    } ?? []
                    
                    project?.tasks = tasks
                    
                    self.projects.removeAll {
                        if project == $0 {
                            return true
                        }
                        return false
                    }
                    self.projects.append(project!)
                }
                
                return project
            } ?? []
        }
    }
    
    
}

extension ProjectRepository {
    static func add(_ project: Project) {
        let store = Firestore.firestore()
        //let userId = AuthService.currentUser!.uid
        
        do {
            let newProject = project
            print("managerId is \(newProject.managerId)")
//            if userId.isEmpty{
//                newProject.managerId = ""
//            }else{
//                newProject.managerId = userId
//            }
            let docRef = try store.collection("projects").addDocument(from: newProject)
            
            let uuid = UUID().uuidString
            let exampleTask = Task(id: uuid, title: "Your first task", content: "Get to know your project", taskStatus: .awaiting, timestamp: Date().timeIntervalSince1970, dueTimestamp: nil, creatorId: project.managerId, assigneesId: [])
            
            try docRef.collection("tasks").document(uuid).setData(from: exampleTask)
            
            //self.get()
        } catch {
            fatalError("Unable to add project: \(error.localizedDescription).")
        }
    }
    
    static func add(task: Task, to project: Project){
        let store = Firestore.firestore()
        
        guard let projectId = project.id else { return }
        
        do {
            try store.collection("projects").document(projectId).collection("tasks").document(task.id).setData(from: task.self)
            store.collection("projects").document(projectId).updateData(["mock":Date().timeIntervalSince1970])
        } catch {
            fatalError("Unable to update project: \(error.localizedDescription).")
        }
    }
    
    static func addTag(label: String, colorString: String, to project: Project){
        let store = Firestore.firestore()
        
        guard let projectId = project.id else { return }
        
        store.collection("projects").document(projectId).setData(["tags":[label: colorString]], merge: true)
    }
    
    static func addTag(to task: Task, in project: Project, label: String, colorString: String){
        let store = Firestore.firestore()
        
        guard let projectId = project.id else { return }
        
        store.collection("projects").document(projectId).collection("tasks").document(task.id).setData(["tags":[label: colorString]], merge: true)
        store.collection("projects").document(projectId).updateData(["mock":Date().timeIntervalSince1970])
    }
    
    static func removeTag(label: String, from project: Project){
        let store = Firestore.firestore()
        
        guard let projectId = project.id else { return }
        
        var map = project.tags!
        map.removeValue(forKey: label)
        
        for task in project.tasks.filter({ t in
            return t.tags?.keys.contains(label) ?? false
        }) {
            var subMap = task.tags!
            subMap.removeValue(forKey: label)
            
            store.collection("projects").document(projectId).collection("tasks").document(task.id).updateData(["tags" : subMap])
        }
        
        store.collection("projects").document(projectId).updateData(["tags":map])
    }
    
    static func removeTag(label: String, from task: Task, in project: Project){
        let store = Firestore.firestore()
        
        guard let projectId = project.id else { return }
        
        var subMap = task.tags!
        subMap.removeValue(forKey: label)
        
        store.collection("projects").document(projectId).collection("tasks").document(task.id).updateData(["tags": subMap])
        
        store.collection("projects").document(projectId).updateData(["mock":Date().timeIntervalSince1970])
    }
    
    static func addCollaborator(userId: String, to projectId: String){
        let store = Firestore.firestore()
        
        store.collection("projects").document(projectId).updateData(["collaboratorIds" : FieldValue.arrayUnion([userId])])
    }
    
    static func removeCollaborator(userId: String, from projectId: String){
        let store = Firestore.firestore()
        
        store.collection("projects").document(projectId).updateData(["collaboratorIds" : FieldValue.arrayRemove([userId])])
    }
    
    static func update(_ project: Project) {
        let store = Firestore.firestore()
        
        guard let projectId = project.id else { return }
        
        do {
            for task in project.tasks {
                try store.collection("projects").document(projectId).collection("tasks").document(task.id).setData(from: task.self)
            }
        } catch {
            fatalError("Unable to update project: \(error.localizedDescription).")
        }
    }
    
    static func update(_ project: Project, task: Task){
        let store = Firestore.firestore()
        
        guard let projectId = project.id else { return }
        
        do {
            try store.collection("projects").document(projectId).collection("tasks").document(task.id).setData(from: task.self)
            store.collection("projects").document(projectId).updateData(["mock":Date().timeIntervalSince1970])
        } catch {
            fatalError("Unable to update project: \(error.localizedDescription).")
        }
    }
    
    static func update(_ project: Project, withName newName: String) {
        let store = Firestore.firestore()
        
        guard let projectId = project.id else { return }
        
        store.collection("projects").document(projectId).updateData(["name" : newName])
    }
    
    static func remove(task: Task, from project: Project){
        let store = Firestore.firestore()
        
        guard let projectId = project.id else { return }
        
        store.collection("projects").document(projectId).collection("tasks").document(task.id).delete { error in
            if let error = error {
                print("Unable to remove task: \(error.localizedDescription)")
            }
            
            print("removed task \(task.id) from \(String(describing: project.id))")
            
            //store.collection("projects").document(projectId).updateData(["mock":Date().timeIntervalSince1970])
        }
    }
    
    func remove(_ project: Project) {
        let store = Firestore.firestore()
        
        guard let projectId = project.id else { return }
        
        guard let index = self.projects.firstIndex(where: {$0.id == project.id}) else {
            return
        }

        self.projects.remove(at: index)
        
        store.collection("projects").document(projectId).delete { error in
            if let error = error {
                print("Unable to remove project: \(error.localizedDescription)")
            }
        }
        
        store.collection("projects").document(projectId).collection("tasks").getDocuments { querySnapshot, err in
            if err != nil {
                print("Error deleting tasks from Project \(projectId)")
            }
            
            querySnapshot?.documents.forEach({ snapshot in
                print("deleting \(snapshot.data())")
                snapshot.reference.delete()
            })
        }
    }
}
