//
//  NewProjectForm.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI

struct UpdateProjectForm: View {
  @State var projectName: String = ""

  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var projectViewModel: ProjectViewModel

  var body: some View {
    VStack(alignment: .center, spacing: 30) {
      VStack(alignment: .leading, spacing: 10) {
        Text("Name")
          .foregroundColor(.gray)
        TextField("Enter the project name", text: $projectName)
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }

      Button(action: updateProject) {
        Text("Save Changes")
          .foregroundColor(.blue)
      }
      Spacer()
    }
    .padding(EdgeInsets(top: 80, leading: 40, bottom: 0, trailing: 40))
  }

  private func updateProject() {
//    let project = Project(name: projectName, tasks: [], managerId: AuthService().user?.uid, timestamp: Date().timeIntervalSince1970)

    //projectViewModel.add(project)
    
    projectViewModel.update(project: projectViewModel.project)

    presentationMode.wrappedValue.dismiss()
  }
}

struct UpdateProjectForm_Previews: PreviewProvider {
  static var previews: some View {
    UpdateProjectForm(projectViewModel: ProjectViewModel(project: testProject))
  }
}

