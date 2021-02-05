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
    
    func removeTask(withId id: String){
        self.project.tasks.removeAll { (task) -> Bool in
            if id == task.id {
                return true
            }
            return false
        }
        projectRepository.update(project)
    }
    
    func update(project: Project) {
        projectRepository.update(project)
    }
    
    func remove() {
        projectRepository.remove(project)
    }
}
