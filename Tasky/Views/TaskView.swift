//
//  TaskView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/4/21.
//

import SwiftUI

struct TaskView: View {
    @ObservedObject var userService: UserService = UserService()
    @State var showDetailSheet: Bool = false
    var task: Task
    var onRemovePressed: (String) -> ()
    var onStatusChanged: (String, TaskStatus) ->()
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        let dateFromTimestamp = Date(timeIntervalSince1970: TimeInterval(TimeInterval(self.task.timestamp)))
        let dateString = dateFormatter.string(from: dateFromTimestamp)

        if task.creatorId != nil {
            userService.fetchUserBy(id: task.creatorId ?? "")
        }
        
        return GeometryReader { geometry in
            VStack(alignment: .leading) {
                HStack{
                    if self.task.taskStatus == .completed {
                        Text("\(task.title)").font(.headline).strikethrough().lineLimit(1)
                    }else{
                        Text("\(task.title)").font(.headline).lineLimit(1)
                    }
                    Spacer()
                }.padding(.leading, 12).padding(.top, 8)
                HStack{
                    Text("\(self.task.content)").font(.subheadline).foregroundColor(.black).opacity(0.8)
                    Spacer()
                }.padding(.leading, 12)
                Spacer()
                HStack{
                    Spacer()
                    Text("created on \(dateString) by \(self.userService.user?.firstName ?? "") \(self.userService.user?.lastName ?? "")").font(.footnote).foregroundColor(.black).opacity(0.5).padding(.trailing, 12).padding(.bottom, 8)
                }.padding(.leading, 12)
            }
            .background(Color.orange)
            .cornerRadius(8)
            .frame(width: geometry.size.width, height: 120)
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: Color(.orange).opacity(0.3), radius: 3, x: 2, y: 2)
            .contextMenu {
                if self.task.taskStatus != TaskStatus.awaiting{
                    Button(action: {
                        onStatusChanged(self.task.id, TaskStatus.awaiting)
                    }) {
                        Text("Await")
                        Image(systemName: "tortoise")
                    }
                }
                if self.task.taskStatus != TaskStatus.inProgress{
                    Button(action: {
                        onStatusChanged(self.task.id, TaskStatus.inProgress)
                    }) {
                        Text("In Progress")
                        Image(systemName: "hourglass")
                    }
                }
                if self.task.taskStatus != TaskStatus.completed{
                    Button(action: {
                        onStatusChanged(self.task.id, TaskStatus.completed)
                    }) {
                        Text("Complete")
                        Image(systemName: "checkmark.shield")
                    }
                }
                if self.task.taskStatus != TaskStatus.aborted{
                    Button(action: {
                        onStatusChanged(self.task.id, TaskStatus.aborted)
                    }) {
                        Text("Abort")
                        Image(systemName: "xmark.shield")
                    }
                }
                Divider()
                Button(action: {
                    onRemovePressed(self.task.id)
                }) {
                    Text("Remove")
                    Image(systemName: "trash")
                }
            }.onTapGesture {
                self.showDetailSheet.toggle()
            }.sheet(isPresented: $showDetailSheet){
                let fullName = "\(self.userService.user?.firstName ?? "") \(self.userService.user?.lastName ?? "")"
                TaskDetailSheet(task: self.task, creatorName: fullName)
            }
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading){
            TaskView(task: Task(id: "", title: "My task", content: "To get something done.", taskStatus: .awaiting, timestamp: Date().timeIntervalSince1970), onRemovePressed: { _ in }, onStatusChanged: {_,_ in })
            TaskView(task: Task(id: "1", title: "My task", content: "To get something done.", taskStatus: .awaiting, timestamp: Date().timeIntervalSince1970), onRemovePressed: { _ in }, onStatusChanged: {_,_ in })
            TaskView(task: Task(id: "2", title: "My task", content: "To get something done.", taskStatus: .awaiting, timestamp: Date().timeIntervalSince1970), onRemovePressed: { _ in }, onStatusChanged: {_,_ in })
        }
    }
}
