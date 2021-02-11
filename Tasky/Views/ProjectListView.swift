//
//  ProjectListView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI
import FASwiftUI

struct ProjectListView: View {
    @ObservedObject var authService: AuthService
    @ObservedObject var userService: UserService = UserService()
    @ObservedObject var projectListViewModel = ProjectListViewModel()
    @State var showForm = false
    @State var showAlert = false
    @State var fullName = ""
    
    init(authService: AuthService) {
        self.authService = authService
        guard let uid = authService.user?.uid else {
            return
        }
        self.userService.fetchUserBy(id: uid)
    }
    
    var body: some View {
        NavigationView {
            VStack{
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        VStack(spacing: 24) {
                            ForEach(projectListViewModel.projectViewModels) { projectViewModel in
                                ProjectView(projectViewModel: projectViewModel, projectListViewModel: projectListViewModel)
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
            .navigationBarItems(leading: HStack{
                Menu(content: {
                    Button(action: { }) {
                        Text("Profile")
                        Image(systemName: "person.crop.square")
                    }
                    Divider()
                    Button(action: { showAlert = true }) {
                        Text("Sign Out")
                        Image(systemName: "figure.walk")
                    }
                }, label: {
                    Image("avatar")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                })
                Text("\(fullName)")
                    .font(.body)
                    .foregroundColor(Color(.systemGray))
            } ,
            trailing:
                Button(action: { showForm.toggle() }) {
                    FAText(iconName: "plus", size: 26)
                })
            //            .navigationBarItems(leading: Button(action: {showAlert = true
            //                                                      }) {
            //                FAText(iconName: "sign-out", size: 24)
            //            } ,trailing: Button(action: { showForm.toggle() }) {
            //                FAText(iconName: "plus", size: 26)
            //            })
        }.navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Sign out?"), message: Text(""), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Yes"), action: {
                showAlert = false
                do {
                    try AuthService.signOut()
                    
                } catch {
                    
                }
            }))
        }.onReceive(userService.$user, perform: { user in
            fullName = ((user?.firstName ?? "") + " " + (user?.lastName ?? "")).trimmingCharacters(in: .whitespaces)
        })
    }
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectListView(authService: AuthService())
    }
}

