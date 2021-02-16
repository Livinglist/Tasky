//
//  TaskListView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/4/21.
//

import SwiftUI
import FASwiftUI
import ConfettiView

fileprivate enum ActiveSheet: Identifiable {
    case newTaskSheet, editProjectSheet
    
    var id: Int {
        hashValue
    }
}

struct TaskListView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @State fileprivate var activeSheet: ActiveSheet?
    @State var selectedTaskStatus: TaskStatus = .awaiting
    @State var showDeleteAlert: Bool = false
    @State var showConfetti: Bool = false
    @State var progressValue: Float
    var onDelete: (Project)->()
    @State var timer:Timer?
    
    init(projectViewModel: ProjectViewModel, onDelete: @escaping (Project)->()) {
        self.projectViewModel = projectViewModel
        self.onDelete = onDelete
        let completedCount = Float(projectViewModel.project.tasks.filter { task -> Bool in
            if task.taskStatus == .completed {
                return true
            }
            return false
        }.count)
        let abortedCount = Float(projectViewModel.project.tasks.filter { task -> Bool in
            if task.taskStatus == .aborted {
                return true
            }
            return false
        }.count)
        let total = Float(projectViewModel.project.tasks.count) - abortedCount
        let val = total == 0 ? 0.0 : (completedCount/total)
        self._progressValue = State(initialValue: val)
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                VStack{
                    ProgressBar(value: $progressValue).frame(height: 24).padding(.horizontal)
                    Picker(selection: $selectedTaskStatus, label: Text("Picker"), content: {
                        Text("Awaiting").tag(TaskStatus.awaiting)
                        Text("In Progress").tag(TaskStatus.inProgress)
                        Text("Completed").tag(TaskStatus.completed)
                        Text("Aborted").tag(TaskStatus.aborted)
                    }).pickerStyle(SegmentedPickerStyle()).padding(.horizontal, 16)
                    taskListOf(taskStatus: selectedTaskStatus).animation(.easeInOut(duration: 0.20))
                }
                if showConfetti {
                    ConfettiView( confetti: [
                                    .text("🎉"),
                                    .text("💪"),
                                    .shape(.circle),
                                    .shape(.triangle),
                    ]).transition(.opacity)
                }
            }
        }
        .navigationBarTitle("\(projectViewModel.project.name)")
        .navigationBarItems(trailing: Menu {
            Button(action: { activeSheet = .editProjectSheet }) {
                HStack{
                    Image(systemName: "square.and.pencil")
                    Text("Edit")
                }
            }
            Button(action: { activeSheet = .newTaskSheet }) {
                Text("Add a task")
                Image(systemName: "plus")
            }
            Divider()
            Button(action: { showDeleteAlert = true }) {
                Text("Delete")
                    Image(systemName: "trash")
            }
        } label:{
            Image(systemName: "ellipsis").font(.system(size: 24))
        }.sheet(item: $activeSheet){ item in
            switch item {
            case .newTaskSheet:
                NewTaskSheet(projectViewModel: projectViewModel)
            case .editProjectSheet:
                UpdateProjectForm(projectViewModel: projectViewModel)
            }
        }.alert(isPresented: $showDeleteAlert, content: {
            Alert(title: Text("Delete this project?"), message: Text("This project will be deleted permanently."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Okay"), action: {
                self.onDelete(projectViewModel.project)
                //projectViewModel.delete()
            }))
        }))
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
                                
                                if selectedStatus == .completed {
                                    showConfetti.toggle()
                                    
                                    self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                                        print("invoked")
                                        withAnimation{
                                            self.showConfetti.toggle()
                                        }
                                        
                                    }
                                }
                                
                                let completedCount = Float(projectViewModel.project.tasks.filter { task -> Bool in
                                    if task.taskStatus == .completed {
                                        return true
                                    }
                                    return false
                                }.count)
                                let abortedCount = Float(projectViewModel.project.tasks.filter { task -> Bool in
                                    if task.taskStatus == .aborted {
                                        return true
                                    }
                                    return false
                                }.count)
                                let total = Float(projectViewModel.project.tasks.count) - abortedCount
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
        TaskListView(projectViewModel: ProjectViewModel(project: Project(name: "My project", tasks: [Task(id: "", title: "This is a task", content: "something needs to be done before blablabla", taskStatus: .awaiting, timestamp: NSDate().timeIntervalSince1970), Task(id: "1", title: "This is a task", content: "something needs to be done before blablabla", taskStatus: .awaiting, timestamp: NSDate().timeIntervalSince1970)], timestamp: Date().timeIntervalSince1970)), onDelete: {_ in})
    }
}
