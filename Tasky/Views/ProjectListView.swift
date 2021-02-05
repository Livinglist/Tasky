//
//  ProjectListView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI
import FontAwesomeSwiftUI

struct ProjectListView: View {
    @ObservedObject var authService: AuthService
    @ObservedObject var projectListViewModel = ProjectListViewModel()
    @State var showForm = false
    
    var body: some View {
        NavigationView {
            VStack{
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        VStack(spacing: 24) {
                            ForEach(projectListViewModel.projectViewModels) { projectViewModel in
                                ProjectView(projectViewModel: projectViewModel)
                                    .padding([.leading, .trailing]).padding(.bottom, 12)
                            }
                        }.frame(width: geometry.size.width, height: 124.0*CGFloat(projectListViewModel.projectViewModels.count))
                    }
                }
            }
            .sheet(isPresented: $showForm) {
                NewProjectForm(projectListViewModel: projectListViewModel)
            }
            .navigationBarTitle("My Projects")
            // swiftlint:disable multiple_closures_with_trailing_closure
            .navigationBarItems(leading: Button(action: {
                                                    do {
                                                        try AuthService.signOut()
                                                        
                                                    } catch {
                                                        
                                                    }  }) {
                Text(AwesomeIcon.signOutAlt.rawValue)
                    .font(.awesome(style: .solid, size: 24))
            } ,trailing: Button(action: { showForm.toggle() }) {
                Image(systemName: "plus")
                    .font(.title)
            })
        }.navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectListView(authService: AuthService() ,projectListViewModel: ProjectListViewModel())
    }
}

