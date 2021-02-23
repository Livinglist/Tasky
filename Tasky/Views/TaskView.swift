//
//  TaskView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/4/21.
//

import SwiftUI

struct TaskView: View {
    @ObservedObject var projectViewModel:ProjectViewModel
    @ObservedObject var userService: UserService = UserService()
    @State var showDetailSheet: Bool = false
    var task: Task
    var onEditPressed: () -> ()
    var onRemovePressed: () -> ()
    var onStatusChanged: (TaskStatus) ->()
    var onChipPressed: (String)->()
    
    init(task: Task, projectViewModel: ProjectViewModel,onEditPressed: @escaping () -> (),onRemovePressed: @escaping () -> (), onStatusChanged: @escaping (TaskStatus) ->(), onChipPressed: @escaping (String) ->()) {
        self.projectViewModel = projectViewModel
        self.onEditPressed = onEditPressed
        self.onRemovePressed = onRemovePressed
        self.onStatusChanged = onStatusChanged
        self.onChipPressed = onChipPressed
        self.task = task
        if task.creatorId != nil {
            self.userService.fetchUserBy(id: task.creatorId ?? "")
        }
    }
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateFromTimestamp = Date(timeIntervalSince1970: TimeInterval(TimeInterval(self.task.timestamp)))
        let dateString = dateFormatter.string(from: dateFromTimestamp)
        
        let dueDateFormatter = DateFormatter()
        dueDateFormatter.dateFormat = "MMM dd, yyyy"
        let dueDateFromTimestamp = self.task.dueTimestamp == nil ? nil : Date(timeIntervalSince1970: TimeInterval(TimeInterval(self.task.dueTimestamp!)))
        let dueDateString = dueDateFromTimestamp == nil ? nil : dateFormatter.string(from: dueDateFromTimestamp!)
        
        var color = Color.orange
        
        if task.taskStatus == .aborted {
            color = Color.gray
        }

        
        return GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                if dueDateString != nil {
                    Text("due on \(dueDateString!)").font(.footnote).foregroundColor(.yellow).opacity(1.0).padding(.leading, 12).padding(.top, 8)
                }
                HStack{
                    if self.task.taskStatus == .completed {
                        Text("\(task.title)").font(.headline).strikethrough().lineLimit(1)
                    }else{
                        Text("\(task.title)").font(.headline).lineLimit(1)
                    }
                    Spacer()
                }.padding(.leading, 12).padding(.top, dueDateString == nil ? 8 : 0)
                HStack{
                    Text("\(self.task.content)").font(.subheadline).lineLimit(2).foregroundColor(.black).opacity(0.8).padding(.vertical, 0)
                    Spacer()
                }.padding(.leading, 12).padding(.vertical, 0)
                Spacer()
                HStack{
                    if task.tags != nil {
                        ForEach(task.tags!.sorted(by: >), id: \.key){ key, value in
                            SmallChip(color: Color(value), label: key) {
                                onChipPressed(key)
                            }
                        }
                    }
                }.padding(.leading, 12).padding(.vertical, 0)
                HStack{
                    Spacer()
                    Text("created on \(dateString) by \(self.userService.user?.firstName ?? "") \(self.userService.user?.lastName ?? "")").font(.footnote).foregroundColor(.black).opacity(0.5).padding(.trailing, 12).padding(.bottom, 8)
                }.padding(.leading, 12).padding(.top, 0)
            }
            .background(color)
            .cornerRadius(8)
            .frame(width: geometry.size.width, height: 120)
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: color.opacity(0.3), radius: 3, x: 2, y: 2)
            .contextMenu {
                if self.task.taskStatus != TaskStatus.awaiting{
                    Button(action: {
                        onStatusChanged(TaskStatus.awaiting)
                    }) {
                        Text("Await")
                        Image(systemName: "tortoise")
                    }
                }
                if self.task.taskStatus != TaskStatus.inProgress{
                    Button(action: {
                        onStatusChanged(TaskStatus.inProgress)
                    }) {
                        Text("In Progress")
                        Image(systemName: "hourglass")
                    }
                }
                if self.task.taskStatus != TaskStatus.completed{
                    Button(action: {
                        onStatusChanged(TaskStatus.completed)
                    }) {
                        Text("Complete")
                        Image(systemName: "checkmark.shield")
                    }
                }
                if self.task.taskStatus != TaskStatus.aborted{
                    Button(action: {
                        onStatusChanged(TaskStatus.aborted)
                    }) {
                        Text("Abort")
                        Image(systemName: "xmark.shield")
                    }
                }
                Divider()
                Button(action: {
                    onEditPressed()
                }) {
                    Text("Edit")
                    Image(systemName: "pencil")
                }
                Divider()
                Button(action: {
                    onRemovePressed()
                }) {
                    Text("Remove")
                    Image(systemName: "trash")
                }
            }.onTapGesture {
                self.showDetailSheet.toggle()
            }.sheet(isPresented: $showDetailSheet){
                let fullName = "\(self.userService.user?.firstName ?? "") \(self.userService.user?.lastName ?? "")"
                TaskDetailSheet(projectViewModel: projectViewModel, task: self.task, creatorName: fullName)
            }
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
//        VStack(alignment: .leading){
//            TaskView(task: Task(id: "", title: "My task", content: "To get something done.", taskStatus: .awaiting, timestamp: Date().timeIntervalSince1970, dueTimestamp: Date().timeIntervalSince1970), onEditPressed: {}, onRemovePressed: { }, onStatusChanged: {_ in })
//            TaskView(task: Task(id: "1", title: "My task", content: "To get something done.", taskStatus: .awaiting, timestamp: Date().timeIntervalSince1970), onEditPressed: {}, onRemovePressed: {  }, onStatusChanged: {_ in })
//            TaskView(task: Task(id: "2", title: "My task", content: "To get something done.", taskStatus: .awaiting, timestamp: Date().timeIntervalSince1970), onEditPressed: {}, onRemovePressed: {  }, onStatusChanged: {_ in })
//        }
    }
}
