//
//  ProjectViewModel.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import Foundation
import Combine


class ProjectViewModel: ObservableObject, Identifiable {
    private let projectRepository = ProjectRepository()
    
    @Published var project: Project
    
    private var cancellables: Set<AnyCancellable> = []
    
    var id = ""
    
    init(project: Project) {
        self.project = project
        
        $project
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
    
    func addTask(task: Task){
        self.project.tasks.append(task)
        projectRepository.update(project)
    }
    
    //    func removeTask(withId id: String){
    //        self.project.tasks.removeAll { (task) -> Bool in
    //            if task.id == id {
    //                return true
    //            }
    //            return false
    //        }
    //        projectRepository.update(project)
    //    }
    
    func updateTaskStatus(withId id: String, to taskStatus: TaskStatus){
        let index = project.tasks.firstIndex(where: { task -> Bool in
            if task.id == id {
                return true
            }
            return false
        })!
        
        let task = project.tasks.remove(at: index)
        
        let newTask = Task(id: task.id, title: task.title, content: task.content, taskStatus: taskStatus, timestamp: task.timestamp)
        project.tasks.append(newTask)
        projectRepository.update(project)
    }
    
    func remove(task: Task){
        projectRepository.remove(task: task, from: self.project)
    }
    
    func update(project: Project) {
        projectRepository.update(project)
    }
    
    func delete() {
        projectRepository.remove(project)
    }
}
