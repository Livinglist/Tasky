//
//  TaskDetailSheet.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/10/21.
//

import SwiftUI

fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 6
    static let indicatorWidth: CGFloat = 60
    static let snapRatio: CGFloat = 0.25
    static let minHeightRatio: CGFloat = 0.3
}

struct TaskDetailSheet: View {
    @ObservedObject var userService: UserService = UserService()
    var task:Task
    var creatorName: String?
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(
                width: Constants.indicatorWidth,
                height: Constants.indicatorHeight
        )
    }
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        let dateFromTimestamp = Date(timeIntervalSince1970: TimeInterval(TimeInterval(self.task.timestamp)))
        let dateString = dateFormatter.string(from: dateFromTimestamp)
        
        
        return VStack {
            indicator.padding()
            HStack{
                if self.task.taskStatus == .completed {
                    Text("\(task.title)").font(.headline).strikethrough()
                }else{
                    Text("\(task.title)").font(.headline)
                }
                Spacer()
            }.padding(.leading, 12).padding(.top, 8).padding(.bottom, 12)
            HStack{
                Text("\(self.task.content)").font(.subheadline).opacity(0.8)
                Spacer()
            }.padding(.leading, 12)
            Spacer()
            HStack{
                Spacer()
                Text("created on \(dateString) by \(creatorName ?? "")").font(.footnote).opacity(0.5).padding(.trailing, 12).padding(.bottom, 8)
            }.padding(.leading, 12)
        }
    }
}

struct TaskDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailSheet(task: Task(id: "", title: "Task", content: "details", taskStatus: .awaiting, timestamp: Date().timeIntervalSince1970, dueTimestamp: nil, creatorId: nil, assigneesId: nil))
    }
}
