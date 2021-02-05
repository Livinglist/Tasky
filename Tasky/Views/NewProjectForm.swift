//
//  NewProjectForm.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI

struct NewProjectForm: View {
  @State var question: String = ""
  @State var answer: String = ""
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var projectListViewModel: ProjectListViewModel

  var body: some View {
    VStack(alignment: .center, spacing: 30) {
      VStack(alignment: .leading, spacing: 10) {
        Text("Question")
          .foregroundColor(.gray)
        TextField("Enter the question", text: $question)
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }
      VStack(alignment: .leading, spacing: 10) {
        Text("Answer")
          .foregroundColor(.gray)
        TextField("Enter the answer", text: $answer)
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }

      Button(action: addProject) {
        Text("Add New Project")
          .foregroundColor(.blue)
      }
      Spacer()
    }
    .padding(EdgeInsets(top: 80, leading: 40, bottom: 0, trailing: 40))
  }

  private func addProject() {
    // 1
    let project = Project(name: question, tasks: [], userId: AuthService().user?.uid)
    // 2
    projectListViewModel.add(project)
    // 3
    presentationMode.wrappedValue.dismiss()
  }
}

struct NewProjectForm_Previews: PreviewProvider {
  static var previews: some View {
    NewProjectForm(projectListViewModel: ProjectListViewModel())
  }
}

