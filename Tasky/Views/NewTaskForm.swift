//
//  NewProjectForm.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI

struct NewTaskForm: View {
    @State var title: String = ""
    @State var content: String = "Details"
    @State var selectedDate: Date = Date()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var projectViewModel: ProjectViewModel
    
    var body: some View {
        Form{
            Section{
                TextField("Title", text: $title)
                TextEditor(text: $content).frame(height: 120)
            }
            
            Section{
                DatePicker("Due Date",selection: $selectedDate)
            }
        }
        //    VStack(alignment: .center, spacing: 30) {
        //      VStack(alignment: .leading, spacing: 10) {
        //        Text("Title")
        //          .foregroundColor(.gray)
        //        TextField("Enter the title", text: $title)
        //          .textFieldStyle(RoundedBorderTextFieldStyle())
        //      }
        //      VStack(alignment: .leading, spacing: 10) {
        //        Text("Content")
        //          .foregroundColor(.gray)
        //        TextField("Enter the content", text: $content)
        //          .textFieldStyle(RoundedBorderTextFieldStyle())
        //      }
        //
        //      Button(action: addProject) {
        //        Text("Add New Task")
        //          .foregroundColor(.blue)
        //      }
        //      Spacer()
        //    }
        //    .padding(EdgeInsets(top: 80, leading: 40, bottom: 0, trailing: 40))
    }
    
    private func addProject() {
        let task = Task(id: UUID().uuidString, title: title, content: content, taskStatus: .awaiting, timestamp: NSDate().timeIntervalSince1970)
        
        projectViewModel.addTask(task: task)
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewTaskForm_Previews: PreviewProvider {
    static var previews: some View {
        NewTaskForm(projectViewModel: ProjectViewModel(project: Project(id: "", name: "", tasks: [], userId: "")))
    }
}

