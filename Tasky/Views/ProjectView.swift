//
//  ProjectView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI

struct ProjectView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @State var showContent: Bool = false
    @State var viewState = CGSize.zero
    @State var showAlert = false
    @State var progressValue:Float
    
    init(projectViewModel: ProjectViewModel) {
        self.projectViewModel = projectViewModel
        let completedCount = Float(projectViewModel.project.tasks.filter { task -> Bool in
            if task.taskStatus == .completed {
                return true
            }
            return false
        }.count)
        let total = Float(projectViewModel.project.tasks.count)
        let val = completedCount/total
        self._progressValue = State(initialValue: val)
        
        print("inside view")
        print(projectViewModel.project.tasks)
    }
    
    var body: some View {
        NavigationLink(destination: TaskListView(projectViewModel: projectViewModel)){
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    HStack{
                        Text("\(projectViewModel.project.name)").font(.title).foregroundColor(.black)
                        Spacer()
                    }.padding(.leading, 12).padding(.top, 8)
                    HStack{
                        Text("\(projectViewModel.project.tasks.count) tasks").font(.body).foregroundColor(.black).opacity(0.8)
                        Spacer()
                    }.padding(.leading, 12)
                    Spacer()
                    //ProgressBar(value: $progressValue, color: Color(.)).frame(height: 24).padding()
                }
                .frame(width: geometry.size.width, height: 120)
                .background(Color.orange)
                .cornerRadius(8)
                .shadow(color: Color(.orange).opacity(0.3), radius: 3, x: 2, y: 2)
            }
        }
    }
    
    //  var frontView: some View {
    //    VStack(alignment: .center) {
    //      Spacer()
    //      Text(projectViewModel.project.name)
    //        .foregroundColor(.white)
    //        .font(.system(size: 20))
    //        .fontWeight(.bold)
    //        .multilineTextAlignment(.center)
    //        .padding(20.0)
    //      Spacer()
    //      if !projectViewModel.project.successful {
    //        Text("You answered this one incorrectly before")
    //          .foregroundColor(.white)
    //          .font(.system(size: 11.0))
    //          .fontWeight(.bold)
    //          .padding()
    //      }
    //    }
    //  }
    //
    //  var backView: some View {
    //    VStack {
    //      // 1
    //      Spacer()
    //      Text(projectViewModel.project.answer)
    //        .foregroundColor(.white)
    //        .font(.body)
    //        .padding(20.0)
    //        .multilineTextAlignment(.center)
    //        .animation(.easeInOut)
    //      Spacer()
    //      // 2
    //      HStack(spacing: 40) {
    //        Button(action: markProjectAsSuccesful) {
    //          Image(systemName: "hand.thumbsup.fill")
    //            .padding()
    //            .background(Color.green)
    //            .font(.title)
    //            .foregroundColor(.white)
    //            .clipShape(Circle())
    //        }
    //        Button(action: markProjectAsUnsuccesful) {
    //          Image(systemName: "hand.thumbsdown.fill")
    //            .padding()
    //            .background(Color.blue)
    //            .font(.title)
    //            .foregroundColor(.white)
    //            .clipShape(Circle())
    //        }
    //      }
    //      .padding()
    //    }
    //    .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
    //  }
    
    func update(project: Project) {
        projectViewModel.update(project: project)
        showContent.toggle()
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        //let project = testData[0]
//        return ProjectView(projectViewModel: ProjectViewModel(project: project))
        return Text("")
    }
}

