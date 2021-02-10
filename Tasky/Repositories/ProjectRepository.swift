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
    
    var listFromFetchingProject = [DocumentSnapshot]()
    
    func fetchProjects(completetion:@escaping ([Project])->()){
        let projectsRef = Firestore.firestore().collection("projects")
        
        projectsRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting projects: \(err)")
            }else{
                self.listFromFetchingProject = querySnapshot!.documents
                
                DispatchQueue.main.async {
                    completetion(self.projects)
                }
            }
        }
    }
    
    func fetchProject(index: Int = 0){
        let doc = listFromFetchingProject[index]
        let data = doc.data()
        let projectId = doc.documentID
        var project = try? doc.data(as: Project.self)
        
        fetchTasksFromDocRef(docRef: doc.reference){ (tasks: [Task]) in
            project?.tasks = tasks
        }
    }
    
    func fetchTasksFromDocRef(docRef: DocumentReference, completion: @escaping (_ tasks: [Task])->()){
        fetchTasks(docRef: docRef)
        completionListner = {
            completion(self.fetchedTasks)
        }
    }
    
    var completionListner: () -> () = {}
    var fetchedTasks = [Task]()
    func fetchTasks(docRef: DocumentReference){
        DispatchQueue.main.async {
            docRef.collection("tasks").getDocuments { (querySnapshot, err) in
                if let err  = err {
                    print("Error fetching tasks")
                    return
                }
                
                self.fetchedTasks = querySnapshot?.documents.compactMap{ document in
                    var task = try? document.data(as: Task.self)
                    return task
                } ?? []
            }
            
            self.completionListner()
        }
        
    }
    
    func get() {
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
            let exampleTask = Task(id: uuid, title: "Your first task", content: "Get to know your project", taskStatus: .awaiting, timestamp: Date().timeIntervalSince1970, dueTimestamp: nil, assigneesId: [])
            
            try docRef.collection("tasks").document(uuid).setData(from: exampleTask)
            
            self.get()
            //            store.collection("projects").whereField("managerId", isEqualTo: userId).addSnapshotListener{ querySnapshot, error in
            //                if let error = error {
            //                    print("Error getting projects: \(error.localizedDescription)")
            //                    return
            //                }
            //
            //                self.projects = querySnapshot?.documents.compactMap { document in
            //                    let map = try? document.data(as: Project.self)
            //                    return map
            //                } ?? []
            //
            //            }
        } catch {
            fatalError("Unable to add project: \(error.localizedDescription).")
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
    
    func remove(task: Task, from project: Project){
        guard let projectId = project.id else { return }
        
        do {
            try store.collection("projects").document(projectId).collection("tasks").document(task.id).delete()
        } catch {
            fatalError("Unable to update project: \(error.localizedDescription).")
        }
    }
    
    func remove(_ project: Project) {
        print("removing project")
        guard let projectId = project.id else { return }
        
        store.collection(path).document(projectId).delete { error in
            if let error = error {
                print("Unable to remove project: \(error.localizedDescription)")
            }
        }
    }
}
