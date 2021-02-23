//
//  NewProjectSheet.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI

struct NewProjectSheet: View {
    @State var projectName: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var projectListViewModel: ProjectListViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Indicator().padding()
//            Text("Name")
//                .foregroundColor(.gray)
            Color.clear.frame(height: 36)
            
            TextField("Enter the project name", text: $projectName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Color.clear.frame(height: 36)
            
            Button(action: addProject) {
                Text("Add New Project")
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40))
    }
    
    private func addProject() {
        guard !projectName.isEmpty else { return }
        
        let project = Project(name: projectName, tasks: [], managerId: AuthService.currentUser?.uid, timestamp: Date().timeIntervalSince1970)
        
        projectListViewModel.add(project)
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewProjectForm_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}

