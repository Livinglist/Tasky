//
//  NewProjectSheet.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI

struct NewTaskSheet: View {
    @State var title: String = ""
    @State var content: String = ""
    @State var selectedDate: Date = Date().advanced(by: 86400) //86400 seconds == 1 day
    @State var enableDueDate: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var projectViewModel: ProjectViewModel
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    TextField("Title", text: $title)
                    TextEditor(text: $content).frame(height: 120)
                }
                
                Section{
                    Toggle(isOn: $enableDueDate, label: {
                        Text("With Due Date")
                    })
                    if enableDueDate {
                        DatePicker("", selection: $selectedDate)
                    }
                }
                
                Button(action: addTask) {
                        Text("Add New Task")
                          .foregroundColor(.blue)
                      }
            }.padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0)).navigationBarTitle("").navigationBarHidden(true)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func addTask() {
        if self.title.isEmpty {
            return
        }
        
        let task = Task(id: UUID().uuidString, title: title, content: content, taskStatus: .awaiting, timestamp: NSDate().timeIntervalSince1970, dueTimestamp: enableDueDate ? selectedDate.timeIntervalSince1970: nil, creatorId: AuthService.currentUser?.uid)
        
        projectViewModel.addTask(task: task)
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewTaskForm_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
//        NewTaskSheet(projectViewModel: ProjectViewModel(project: Project(id: "", name: "", tasks: [], managerId: "",timestamp: Date().timeIntervalSince1970), projectRepo: ProjectRepository))
    }
}

