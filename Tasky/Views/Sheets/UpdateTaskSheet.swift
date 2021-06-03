//
//  UpdateTaskSheet.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/15/21.
//

import SwiftUI

struct UpdateTaskSheet: View {
    @State var title: String = ""
    @State var content: String = ""
    @State var selectedDate: Date = Date().advanced(by: 86400) //86400 seconds == 1 day
    @State var enableDueDate: Bool = false
    @State var task:Task = testTask
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var projectViewModel: ProjectViewModel
    
    init(projectViewModel: ProjectViewModel) {
        self.projectViewModel = projectViewModel
    }
    
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
                
                Button(action: updateTask) {
                        Text("Save changes")
                          .foregroundColor(.blue)
                      }
            }.padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0)).navigationBarTitle("").navigationBarHidden(true).onAppear(perform: {
                self.task = projectViewModel.selectedTask
                self.title = task.title
                self.content = task.content
                if task.dueTimestamp == nil {
                    enableDueDate = false
                } else {
                    enableDueDate = true
                    selectedDate = Date(timeIntervalSince1970: task.dueTimestamp!)
                }
            })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func updateTask() {
        if self.title.isEmpty {
            return
        }
        
        let updatedTask = Task(id: self.task.id, title: title, content: content, taskStatus: self.task.taskStatus, timestamp: self.task.timestamp, dueTimestamp: enableDueDate ? selectedDate.timeIntervalSince1970: nil, creatorId: self.task.creatorId, tags: self.task.tags)
        
        projectViewModel.updateTask(task: updatedTask)
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct UpdateTaskSheet_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
