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
    
    private let authenticationService = AuthService()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        authenticationService.$user
            .compactMap { user in
                if user?.uid.isEmpty ?? true {
                    return self.testUserId
                }else{
                    return user?.uid
                }
            }
            .assign(to: \.userId, on: self)
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
    }
    
    func add(_ project: Project) {
        print("adding project")
        do {
            var newProject = project
            if userId.isEmpty{
                newProject.managerId = testUserId
            }else{
                newProject.managerId = userId
            }
            let docRef = try store.collection("projects").addDocument(from: newProject)
            
            let uuid = UUID().uuidString
            let exampleTask = Task(id: uuid, title: "Your first task", content: "Get to know your project", taskStatus: .awaiting, timestamp: Date().timeIntervalSince1970, dueTimestamp: nil, creatorId: project.managerId, assigneesId: [])
            
            try docRef.collection("tasks").document(uuid).setData(from: exampleTask)
            
            //self.get()
        } catch {
            fatalError("Unable to add project: \(error.localizedDescription).")
        }
    }
    
    func add(task: Task, to project: Project){
        guard let projectId = project.id else { return }
        
        do {
            try store.collection("projects").document(projectId).collection("tasks").document(task.id).setData(from: task.self)
        } catch {
            fatalError("Unable to update project: \(error.localizedDescription).")
        }
    }
    
    func update(_ project: Project) {
        print("updating project")
        guard let projectId = project.id else { return }
        
        do {
            for task in project.tasks {
                try store.collection("projects").document(projectId).collection("tasks").document(task.id).setData(from: task.self)
            }
        } catch {
            fatalError("Unable to update project: \(error.localizedDescription).")
        }
    }
    
    func update(_ project: Project, withName newName: String) {
        print("updating project name")
        guard let projectId = project.id else { return }
        
        do {
            try? store.collection("projects").document(projectId).updateData(["name" : newName])
        } catch {
            fatalError("Unable to update project: \(error.localizedDescription).")
        }
    }
    
    func remove(task: Task, from project: Project){
        guard let projectId = project.id else { return }
        
        store.collection("projects").document(projectId).collection("tasks").document(task.id).delete { error in
            if let error = error {
                print("Unable to remove task: \(error.localizedDescription)")
            }
            
            print("removed task \(task.id) from \(project.id)")
        }
    }
    
    func remove(_ project: Project) {
        print("removing project")
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
