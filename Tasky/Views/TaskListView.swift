//
//  TaskListView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/4/21.
//

import SwiftUI
import FontAwesomeSwiftUI

struct TaskListView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @State var showForm: Bool = false
    @State var selectedTaskStatus: TaskStatus = .awaiting
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                Picker(selection: $selectedTaskStatus, label: Text("Picker"), content: {
                    Text("Awaiting").tag(TaskStatus.awaiting)
                    Text("In Progress").tag(TaskStatus.inProgress)
                    Text("Completed").tag(TaskStatus.completed)
                    Text("Aborted").tag(TaskStatus.aborted)
                }).pickerStyle(SegmentedPickerStyle()).padding(.horizontal, 16)
                taskListOf(taskStatus: selectedTaskStatus)
            }
        }
        .sheet(isPresented: $showForm) {
            NewTaskForm(projectViewModel: projectViewModel)
        }
        .navigationBarTitle("\(projectViewModel.project.name)")
        .navigationBarItems(trailing: Button(action: { showForm.toggle() }) {
            Image(systemName: "plus")
                .font(.title)
        })
    }
    
    func taskListOf(taskStatus: TaskStatus) -> some View {
        return GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(spacing: 24) {
                    ForEach(projectViewModel.project.tasks.filter({ task -> Bool in
                        if task.taskStatus == taskStatus{
                            return true
                        }
                        return false
                    })) { task in
                        TaskView(task: task, onRemovePressed: { taskId in
                            withAnimation {
                                projectViewModel.removeTask(withId: taskId)
                            }
                        })
                        .padding([.leading, .trailing]).padding(.bottom, 12).transition(.slide)
                    }
                }.frame(width: geometry.size.width, height: 124.0*CGFloat(projectViewModel.project.tasks.count))
            }
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(projectViewModel: ProjectViewModel(project: Project(name: "My project", tasks: [Task(id: "", title: "This is a task", content: "something needs to be done before blablabla", taskStatus: .awaiting, timestamp: NSDate().timeIntervalSince1970)])))
    }
}
