//
//  NewProjectSheet.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI

struct EmailSignInForm: View {
  @State var question: String = ""
  @State var answer: String = ""
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    VStack(alignment: .center, spacing: 30) {
      VStack(alignment: .leading, spacing: 10) {
        Text("Email")
          .foregroundColor(.gray)
        TextField("Enter the email", text: $question)
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }
      VStack(alignment: .leading, spacing: 10) {
        Text("Password")
          .foregroundColor(.gray)
        TextField("Enter the password", text: $answer)
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }

      Button(action: addProject) {
        Text("Sign In")
          .foregroundColor(.blue)
      }
      Spacer()
    }
    .padding(EdgeInsets(top: 80, leading: 40, bottom: 0, trailing: 40))
  }

  private func addProject() {
    
    presentationMode.wrappedValue.dismiss()
  }
}

struct EmailSignInForm_Previews: PreviewProvider {
  static var previews: some View {
    EmailSignInForm()
  }
}

