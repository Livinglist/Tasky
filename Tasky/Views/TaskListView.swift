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
    case newTaskSheet, editProjectSheet, updateTaskSheet, peopleSheet
    
    var id: Int {
        hashValue
    }
}

fileprivate enum ActiveAlert: Identifiable {
    case deleteProjectAlert, removeCollabAlert
    
    var id: Int {
        hashValue
    }
}

var selectedTask: Task = testTask

struct TaskListView: View {
    @ObservedObject var projectListViewModel: ProjectListViewModel
    @ObservedObject var userService: UserService = UserService()
    @ObservedObject var projectViewModel: ProjectViewModel
    @State fileprivate var activeSheet: ActiveSheet?
    @State fileprivate var activeAlert: ActiveAlert?
    @State var selectedTaskStatus: TaskStatus = .awaiting
    @State var showConfetti: Bool = false
    @State var showActionSheet: Bool = false
    @State var progressValue: Float
    @State var selectedCollaborator: TaskyUser?
    var onDelete: (Project)->()
    @State var timer:Timer?
    
    init(projectListViewModel: ProjectListViewModel,projectViewModel: ProjectViewModel, onDelete: @escaping (Project)->()) {
        self.projectListViewModel = projectListViewModel
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
        
        self.userService.fetchUserBy(id: projectViewModel.project.managerId!)
        
        guard let ids = projectViewModel.project.collaboratorIds else { return }
        
        self.userService.fetchUsersBy(ids: ids)
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                VStack{
                    ProgressBar(value: $progressValue).frame(height: 24).padding(.horizontal)
                    Picker(selection: $selectedTaskStatus.animation(), label: Text("Picker"), content: {
                        Text("Awaiting").tag(TaskStatus.awaiting)
                        Text("In Progress").tag(TaskStatus.inProgress)
                        Text("Completed").tag(TaskStatus.completed)
                        Text("Aborted").tag(TaskStatus.aborted)
                    }).pickerStyle(SegmentedPickerStyle()).padding(.horizontal, 16)
                    taskListOf(taskStatus: selectedTaskStatus)
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
        .navigationBarItems(trailing: HStack{
            collabMenu
            Menu {
                Button(action: { activeSheet = .editProjectSheet }) {
                    Image(systemName: "square.and.pencil")
                    Text("Edit")
                }
                Button(action: { activeSheet = .newTaskSheet }) {
                    Text("Add a task")
                    Image(systemName: "plus")
                }
                if AuthService.currentUser!.uid == projectViewModel.project.managerId {
                    Divider()
                    Button(action: { activeAlert = .deleteProjectAlert }) {
                        Text("Delete")
                        Image(systemName: "trash")
                    }
                } else {
                    Divider()
                    Button(action: { activeAlert = .removeCollabAlert }) {
                        Text("Leave")
                        Image(systemName: "figure.wave")
                    }
                }
            } label:{
                Image(systemName: "ellipsis").font(.system(size: 24))
            }
        }.sheet(item: $activeSheet){ item in
            switch item {
            case .newTaskSheet:
                NewTaskSheet(projectViewModel: projectViewModel)
            case .editProjectSheet:
                UpdateProjectForm(projectViewModel: projectViewModel)
            case .updateTaskSheet:
                UpdateTaskSheet(projectViewModel: projectViewModel)
            case .peopleSheet:
                PeopleSheet(projectViewModel: projectViewModel)
            }
        }.alert(item: $activeAlert, content: { item in
            switch item {
            case .deleteProjectAlert:
                return Alert(title: Text("Delete this project?"), message: Text("This project will be deleted permanently."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Okay"), action: {
                self.onDelete(projectViewModel.project)
                //projectViewModel.delete()
            }))
            case .removeCollabAlert:
                return Alert(title: Text("Remove yourself from this project?"), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Okay"), action: {
                projectViewModel.removeCollaborator(userId: AuthService.currentUser!.uid)
                    
                    //For some reasons, line above does not notify viewmodel with the change.
                    //Below is the walk-around.
                    projectListViewModel.remove(id: self.projectViewModel.project.id!)
            }))
            }
        }).actionSheet(isPresented: $showActionSheet){
            ActionSheet(title: Text("\(selectedCollaborator!.fullName)"), buttons: [
                .destructive(Text("Remove")) {
                    projectViewModel.removeCollaborator(userId: selectedCollaborator!.id)
                },
                    .cancel()
                ])
        }
        )
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
                        TaskView(task: task, onEditPressed: {
                            activeSheet = .updateTaskSheet
                            projectViewModel.selected(task: task)
                        }, onRemovePressed: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
                                withAnimation(.easeInOut(duration: 0.20)) {
                                    projectViewModel.remove(task: task)
                                }
                            }
                        }, onStatusChanged: { selectedStatus in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
                                let taskId = task.id
                                withAnimation(.easeInOut(duration: 0.20)){
                                    projectViewModel.updateTaskStatus(withId: taskId, to: selectedStatus)
                                    
                                    if selectedStatus == .completed {
                                        showConfetti.toggle()
                                        
                                        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
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
                            }
                            
                        })
                        .padding([.leading, .trailing]).padding(.bottom, 8).transition(.slide)
                    }
                }.frame(width: geometry.size.width, height: 128.0*CGFloat(filteredTasks.count), alignment: .leading)
            }
        }
    }
    
    var collabMenu:some View {
        let participants = self.projectViewModel.project.collaboratorIds
        
        return Menu {
            Button(action: {
                
            }) {
                Text("\(self.userService.user!.fullName)")
                Image(systemName: "binoculars.fill")
            }
            
            if participants != nil {
                ForEach(self.userService.resultUsers){ taskyUser in
                    Button(action: {
                        if AuthService.currentUser!.uid == projectViewModel.project.managerId {
                            self.selectedCollaborator = taskyUser
                            self.showActionSheet.toggle()
                        }
                    }) {
                        Text("\(taskyUser.fullName)")
                    }
                }
            }
            
            if AuthService.currentUser!.uid == projectViewModel.project.managerId {
                Divider()
                Button(action: { self.activeSheet = .peopleSheet }) {
                    Text("Add collaborator")
                    Image(systemName: "person.fill.badge.plus")
                }
            }
            
        } label:{
            Image(systemName: "person.2.fill").font(.system(size: 22)).foregroundColor(.blue)
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
//        TaskListView(projectViewModel: ProjectViewModel(project: Project(name: "My project", tasks: [Task(id: "", title: "This is a task", content: "something needs to be done before blablabla", taskStatus: .awaiting, timestamp: NSDate().timeIntervalSince1970), Task(id: "1", title: "This is a task", content: "something needs to be done before blablabla", taskStatus: .awaiting, timestamp: NSDate().timeIntervalSince1970)], timestamp: Date().timeIntervalSince1970)), onDelete: {_ in})
    }
}
