//
//  ProjectListViewModel.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import Foundation

import Combine


class ProjectListViewModel: ObservableObject {
    
    @Published var projectViewModels: [ProjectViewModel] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var projectRepository:ProjectRepository
    
    init(authService: AuthService) {
        self.projectRepository = ProjectRepository(authService: authService)
        
        projectRepository.$projects.map { projects in
            return projects.map(ProjectViewModel.init).sorted { (lfs, rhs) -> Bool in
                let res = lfs.project.name.compare(rhs.project.name, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)
                if res == .orderedAscending {
                    return true
                } else {
                    return false
                }
            }
        }
        .assign(to: \.projectViewModels, on: self)
        .store(in: &cancellables)
    }
    
    func add(_ project: Project) {
        ProjectRepository.add(project)
    }
    
    func delete(project: Project){
        projectRepository.remove(project)
    }
    
    func remove(id: String){
        projectViewModels.removeAll { model in
            if model.project.id == id {
                return true
            }
            return false
        }
    }
}

