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
    var selectedTask: Task
    
    private var cancellables: Set<AnyCancellable> = []
    
    var id = ""
    
    init(project: Project) {
        self.project = project
        self.selectedTask = testTask
        
        $project
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
    
    func addTask(task: Task){
        self.project.tasks.append(task)
        projectRepository.add(task: task, to: self.project)
    }
    
    func updateTask(task: Task){
        let index = project.tasks.firstIndex(where: { t -> Bool in
            if task.id == t.id {
                return true
            }
            return false
        })!
        
        project.tasks.remove(at: index)
        
        let updatedTask = Task(id: task.id, title: task.title, content: task.content, taskStatus: task.taskStatus, timestamp: task.timestamp, dueTimestamp: task.dueTimestamp, creatorId: task.creatorId, assigneesId: task.assigneesId)
        project.tasks.insert(updatedTask, at: index)
        projectRepository.update(project, task: updatedTask)
    }
    
    func updateTaskStatus(withId id: String, to taskStatus: TaskStatus){
        let index = project.tasks.firstIndex(where: { task -> Bool in
            if task.id == id {
                return true
            }
            return false
        })!
        
        let task = project.tasks.remove(at: index)
        
        let updatedTask = Task(id: task.id, title: task.title, content: task.content, taskStatus: taskStatus, timestamp: task.timestamp, dueTimestamp: task.dueTimestamp, creatorId: task.creatorId, assigneesId: task.assigneesId)
        project.tasks.insert(updatedTask, at: index)
        projectRepository.update(project, task: updatedTask)
    }
    
    func remove(task: Task){
        guard let index = self.project.tasks.firstIndex(where: {$0.id == task.id}) else {
            return
        }
        self.project.tasks.remove(at: index)
        projectRepository.remove(task: task, from: self.project)
    }
    
    func update(withNewName newName: String) {
        self.project.name = newName
        projectRepository.update(self.project, withName: newName)
    }
    
    func selected(task: Task){
        self.selectedTask = task
    }
}
