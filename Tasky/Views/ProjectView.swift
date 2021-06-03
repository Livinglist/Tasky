//
//  ProjectView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI

struct ProjectView: View{    
    @ObservedObject var projectViewModel: ProjectViewModel
    @ObservedObject var projectListViewModel: ProjectListViewModel
    @State var showContent: Bool = false
    @State var viewState = CGSize.zero
    @State var showAlert = false
    @State var progressValue:Float
    
    init(projectViewModel: ProjectViewModel, projectListViewModel: ProjectListViewModel) {
        self.projectViewModel = projectViewModel
        self.projectListViewModel = projectListViewModel
        let completedCount = Float(projectViewModel.project.tasks.filter { task -> Bool in
            if task.taskStatus == .completed {
                return true
            }
            return false
        }.count)
        let total = Float(projectViewModel.project.tasks.count)
        let val = completedCount/total
        self._progressValue = State(initialValue: val)
    }
    
    var body: some View {
        NavigationLink(destination: TaskListView(projectListViewModel: projectListViewModel,projectViewModel: projectViewModel, onDelete: { project in
            print("first layer of ondelete")
            projectListViewModel.delete(project: project)
        })){
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    HStack{
                        Text("\(projectViewModel.project.name)").font(.title).foregroundColor(.black).lineLimit(1)
                        Spacer()
                    }.padding(.leading, 12).padding(.top, 8)
                    HStack{
                        Text("\(projectViewModel.project.tasks.count) tasks").font(.body).foregroundColor(.black).opacity(0.8)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(Color(.systemGray4)).imageScale(.small).padding(.trailing, 12)
                    }.padding(.leading, 12)
                    Spacer()
                    ScrollView(.horizontal){
                        HStack{
                            Avatar(userId: projectViewModel.project.managerId!).equatable()
                            ForEach(projectViewModel.project.collaboratorIds ?? [], id: \.self){ id in
                                Avatar(userId: id).equatable().padding(.leading, 0)
                            }
                        }.padding([.leading, .bottom], 12)
                    }
                    //ProgressBar(value: $progressValue, color: Color(.)).frame(height: 24).padding()
                }
                .frame(width: geometry.size.width, height: 120)
                .background(Color.orange)
                .cornerRadius(8)
                .shadow(color: Color(.orange).opacity(0.3), radius: 3, x: 2, y: 2)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        //let project = testData[0]
//        return ProjectView(projectViewModel: ProjectViewModel(project: project))
        return Text("")
    }
}

