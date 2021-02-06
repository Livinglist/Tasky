//
//  TaskView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/4/21.
//

import SwiftUI

struct TaskView: View {
    var task: Task
    var onRemovePressed: (String) -> ()
    var onStatusChanged: (String, TaskStatus) ->()
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        let dateFromTimestamp = Date(timeIntervalSince1970: TimeInterval(TimeInterval(self.task.timestamp)))
        let dateString = dateFormatter.string(from: dateFromTimestamp)
        
        return GeometryReader { geometry in
            VStack(alignment: .leading) {
                HStack{
                    Text("\(task.title)").font(.title)
                    Spacer()
                }.padding(.leading, 12).padding(.top, 8)
                HStack{
                    Text("\(self.task.content)").font(.body).foregroundColor(.black).opacity(0.8)
                    Spacer()
                }.padding(.leading, 12)
                Spacer()
                HStack{
                    Spacer()
                    Text("created on \(dateString) by George").font(.footnote).foregroundColor(.black).opacity(0.5).padding(.trailing, 12).padding(.bottom, 8)
                }.padding(.leading, 12)
            }
            .background(Color.orange)
            .cornerRadius(8)
            .frame(width: geometry.size.width, height: 120)
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: Color(.orange).opacity(0.3), radius: 3, x: 2, y: 2).contextMenu {
                if self.task.taskStatus != TaskStatus.awaiting{
                    Button(action: {
                        onStatusChanged(self.task.id, TaskStatus.awaiting)
                    }) {
                        Text("Await")
                        //Image(systemName: "trash")
                    }
                }
                if self.task.taskStatus != TaskStatus.inProgress{
                    Button(action: {
                        onStatusChanged(self.task.id, TaskStatus.inProgress)
                    }) {
                        Text("In Progress")
                        //Image(systemName: "trash")
                    }
                }
                if self.task.taskStatus != TaskStatus.completed{
                    Button(action: {
                        onStatusChanged(self.task.id, TaskStatus.completed)
                    }) {
                        Text("Complete")
                        //Image(systemName: "trash")
                    }
                }
                if self.task.taskStatus != TaskStatus.aborted{
                    Button(action: {
                        onStatusChanged(self.task.id, TaskStatus.aborted)
                    }) {
                        Text("Abort")
                        //Image(systemName: "trash")
                    }
                }
                Divider()
                Button(action: {
                    onRemovePressed(self.task.id)
                }) {
                    Text("Remove")
                    Image(systemName: "trash")
                }
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
