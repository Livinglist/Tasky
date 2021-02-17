//
//  ProjectViewModel.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import Foundation
import Combine


class ProjectViewModel: ObservableObject, Identifiable {
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
        ProjectRepository.add(task: task, to: self.project)
    }
    
    func addCollaborator(userId: String){
        guard let projectId = self.project.id else { return }
        ProjectRepository.addCollaborator(userId: userId, to: projectId)
    }
    
    func removeCollaborator(userId: String){
        guard let projectId = self.project.id else { return }
        ProjectRepository.removeCollaborator(userId: userId, from: projectId)
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
        ProjectRepository.update(project, task: updatedTask)
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
        ProjectRepository.update(project, task: updatedTask)
    }
    
    func remove(task: Task){
        guard let index = self.project.tasks.firstIndex(where: {$0.id == task.id}) else {
            return
        }
        self.project.tasks.remove(at: index)
        ProjectRepository.remove(task: task, from: self.project)
    }
    
    func update(withNewName newName: String) {
        self.project.name = newName
        ProjectRepository.update(self.project, withName: newName)
    }
    
    func selected(task: Task){
        self.selectedTask = task
    }
}
