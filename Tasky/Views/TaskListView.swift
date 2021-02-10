//
//  TaskListView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/4/21.
//

import SwiftUI
import FASwiftUI



struct TaskListView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @State var showForm: Bool = false
    @State var showUpdateProjectForm: Bool = false
    @State var selectedTaskStatus: TaskStatus = .awaiting
    @State var progressValue: Float
    
    init(projectViewModel: ProjectViewModel) {
        self.projectViewModel = projectViewModel
        let completedCount = Float(projectViewModel.project.tasks.filter { task -> Bool in
            if task.taskStatus == .completed {
                return true
            }
            return false
        }.count)
        let total = Float(projectViewModel.project.tasks.count)
        let val = total == 0 ? 0.0 : (completedCount/total)
        self._progressValue = State(initialValue: val)
    }
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                ProgressBar(value: $progressValue).frame(height: 24).padding(.horizontal)
                Picker(selection: $selectedTaskStatus, label: Text("Picker"), content: {
                    Text("Awaiting").tag(TaskStatus.awaiting)
                    Text("In Progress").tag(TaskStatus.inProgress)
                    Text("Completed").tag(TaskStatus.completed)
                    Text("Aborted").tag(TaskStatus.aborted)
                }).pickerStyle(SegmentedPickerStyle()).padding(.horizontal, 16)
                taskListOf(taskStatus: selectedTaskStatus).animation(.easeIn)
            }
        }
        
        .navigationBarTitle("\(projectViewModel.project.name)")
        .navigationBarItems(trailing: HStack{
            Button(action: { showUpdateProjectForm.toggle() }) {
                FAText(iconName: "edit", size: 23)
            }.padding(.trailing, 12).sheet(isPresented: $showUpdateProjectForm) {
                withAnimation{
                    UpdateProjectForm(projectViewModel: projectViewModel)
                }
            }

            Button(action: { showForm.toggle() }) {
                FAText(iconName: "plus", size: 26)
            }.sheet(isPresented: $showForm) {
                withAnimation{
                    NewTaskForm(projectViewModel: projectViewModel)
                }
            }
        })
    }
    
    func taskListOf(taskStatus: TaskStatus) -> some View {
        let filteredTasks = projectViewModel.project.tasks.filter({ task -> Bool in
            if task.taskStatus == taskStatus{
                return true
            }
            return false
        })
        
        return GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack{
                    ForEach(filteredTasks) { task in
                        TaskView(task: task, onRemovePressed: { taskId in
                            withAnimation {
                                projectViewModel.remove(task: task)
                            }
                        }, onStatusChanged: { (taskId: String, selectedStatus: TaskStatus) in
                            withAnimation{
                                projectViewModel.updateTaskStatus(withId: taskId, to: selectedStatus)
                                
                                let completedCount = Float(projectViewModel.project.tasks.filter { task -> Bool in
                                    if task.taskStatus == .completed {
                                        return true
                                    }
                                    return false
                                }.count)
                                let total = Float(projectViewModel.project.tasks.count)
                                let val = completedCount/total
                                self.progressValue = val
                            }
                        })
                        .padding([.leading, .trailing]).padding(.bottom, 8)
                    }
                }.frame(width: geometry.size.width, height: 128.0*CGFloat(filteredTasks.count), alignment: .leading)
            }
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(projectViewModel: ProjectViewModel(project: Project(name: "My project", tasks: [Task(id: "", title: "This is a task", content: "something needs to be done before blablabla", taskStatus: .awaiting, timestamp: NSDate().timeIntervalSince1970), Task(id: "1", title: "This is a task", content: "something needs to be done before blablabla", taskStatus: .awaiting, timestamp: NSDate().timeIntervalSince1970)], timestamp: Date().timeIntervalSince1970)))
    }
}
