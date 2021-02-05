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
        // 3
        self?.get()
      }
      .store(in: &cancellables)
  }

  func get() {
    print(userId)
    print(testUserId)
    print(path)
    store.collection(path).document(userId).collection(path)
      .addSnapshotListener { querySnapshot, error in
        if let error = error {
          print("Error getting projects: \(error.localizedDescription)")
          return
        }

        self.projects = querySnapshot?.documents.compactMap { document in
          try? document.data(as: Project.self)
        } ?? []
      }
  }

  // 4
  func add(_ project: Project) {
    do {
        var newProject = project
        if userId.isEmpty{
            newProject.userId = testUserId
        }else{
            newProject.userId = userId
        }
        _ = try store.collection(path).document(newProject.userId ?? testUserId).collection(path).addDocument(from: newProject)
    } catch {
      fatalError("Unable to add project: \(error.localizedDescription).")
    }
    
//    do {
//      var newProject = project
//      newProject.userId = userId
//      _ = try store.collection(path).addDocument(from: newProject)
//    } catch {
//      fatalError("Unable to add project: \(error.localizedDescription).")
//    }
  }

  func update(_ project: Project) {

    guard let projectId = project.id else { return }


    do {
        try store.collection(path).document(project.userId ?? testUserId).collection(path).document(projectId).setData(from: project)
    } catch {
      fatalError("Unable to update project: \(error.localizedDescription).")
    }
    
//    // 1
//    guard let projectId = project.id else { return }
//
//    // 2
//    do {
//      // 3
//        try store.collection(path).document(projectId).setData(from: project)
//    } catch {
//      fatalError("Unable to update project: \(error.localizedDescription).")
//    }
  }

  func remove(_ project: Project) {
    guard let projectId = project.id else { return }

    store.collection(path).document(projectId).delete { error in
      if let error = error {
        print("Unable to remove project: \(error.localizedDescription)")
      }
    }
  }
}
