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

  @Published var projectRepository = ProjectRepository()

  init() {
    projectRepository.$projects.map { projects in
        print(projects)
        return projects.map(ProjectViewModel.init)
    }
    .assign(to: \.projectViewModels, on: self)
    .store(in: &cancellables)
  }

  func add(_ project: Project) {
    projectRepository.add(project)
  }
}

