//
//  TaskDetailSheet.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/10/21.
//

import SwiftUI

fileprivate enum ActiveActionSheet: Identifiable {
    case addTagSheet, removeTagSheet
    
    var id: Int {
        hashValue
    }
}


struct TaskDetailSheet: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @ObservedObject var userService: UserService = UserService()
    @State fileprivate var activeActionSheet: ActiveActionSheet?
    @State var showRemoveTagAlert: Bool = false
    @State var selectedTag:String?
    var task:Task
    var creatorName: String?
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        let dateFromTimestamp = Date(timeIntervalSince1970: TimeInterval(TimeInterval(self.task.timestamp)))
        let dateString = dateFormatter.string(from: dateFromTimestamp)
        
        
        return VStack {
            Indicator().padding()
            HStack{
                if task.tags != nil {
                    ForEach(task.tags!.sorted(by: >), id: \.key){ key, value in
                        Chip(color: Color(value), label: key) {
                            self.selectedTag = key
                            self.activeActionSheet = .removeTagSheet
                        }
                    }
                }
                Button(action: {
                    if projectViewModel.project.tags != nil {
                        self.activeActionSheet = .addTagSheet
                    }
                }, label: {
                    Image(systemName: "plus.circle").font(.system(size: 24)).foregroundColor(.blue)
                })
                Spacer()
            }.padding(.leading, 12).padding(.bottom, 0)
            HStack{
                if self.task.taskStatus == .completed {
                    Text("\(task.title)").font(.headline).strikethrough()
                }else{
                    Text("\(task.title)").font(.headline)
                }
                Spacer()
            }.padding(.leading, 12).padding(.top, 8).padding(.bottom, 12)
            HStack{
                Text("\(task.content)").font(.subheadline).opacity(0.8)
                Spacer()
            }.padding(.leading, 12)
            Spacer()
            HStack{
                Spacer()
                Text("created on \(dateString) by \(creatorName ?? "")").font(.footnote).opacity(0.5).padding(.trailing, 12).padding(.bottom, 8)
            }.padding(.leading, 12)
        }.actionSheet(item: $activeActionSheet) { item in
            switch item {
            case .addTagSheet:
                return addTagSheet
            case .removeTagSheet:
                return removeTagSheet
            }
        }.alert(isPresented: $showRemoveTagAlert, content: {
            Alert(title: Text("Remove \(selectedTag!)?"), message: Text(""), primaryButton: .default(Text("Cancel")), secondaryButton: .default(Text("Yes"), action: {
                projectViewModel.removeTag(label: selectedTag!, from: task)
            }))

        })
    }
    
    var addTagSheet: ActionSheet{
        let tags = projectViewModel.project.tags!
        var buttons:[ActionSheet.Button] = []
        
        for (key, value) in tags {
            buttons.append(
                .default(Text(key), action: {
                    projectViewModel.addTag(toTaskWithId: self.task.id, label: key, colorString: value)
                }))
        }
        
        buttons.append(.cancel())
        
        return ActionSheet(title: Text("Add a tag"), buttons: buttons)
    }
    
    var removeTagSheet: ActionSheet{
        var buttons:[ActionSheet.Button] = []
        
        buttons.append(.default(Text("Remove"), action: {
            self.showRemoveTagAlert.toggle()
        }))
        buttons.append(.cancel())
        
        return ActionSheet(title: Text("\(selectedTag!)"), buttons: buttons)
    }

}

struct TaskDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
//        TaskDetailSheet(task: Task(id: "", title: "Task", content: "details", taskStatus: .awaiting, timestamp: Date().timeIntervalSince1970, dueTimestamp: nil, creatorId: nil, assigneesId: nil))
    }
}
