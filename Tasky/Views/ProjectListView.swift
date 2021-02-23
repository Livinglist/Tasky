//
//  ProjectListView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI
import SDWebImageSwiftUI
import FASwiftUI

struct ProjectListView: View {
    @ObservedObject var authService: AuthService
    @ObservedObject var userService: UserService = UserService()
    @ObservedObject var projectListViewModel:ProjectListViewModel
    @State var showForm = false
    @State var showAlert = false
    @State var showProfileSheet = false
    @State var fullName = ""
    
    init(authService: AuthService) {
        self.authService = authService
        self.projectListViewModel = ProjectListViewModel(authService: authService)
        guard let uid = authService.user?.uid else {
            return
        }
        self.userService.fetchUserBy(id: uid)
    }
    
    var leadingItem: some View {
        HStack{
            Menu(content: {
                Button(action: { showProfileSheet = true }) {
                    Text("Profile")
                    Image(systemName: "person.crop.square")
                }
                Divider()
                Button(action: { showAlert = true }) {
                    Text("Sign Out")
                    Image(systemName: "figure.walk")
                }
            }, label: {
                if authService.user != nil {
                    Avatar(userId: authService.user!.uid).equatable()
                }
            }).frame(width: 40, height: 40)
            Text("\(fullName)")
                .font(.body)
                .foregroundColor(Color(.systemGray))
        }.sheet(isPresented: $showProfileSheet){
            ProfileSheet(authService: self.authService, userService: self.userService)
        }
        
    }
    
    var body: some View {
        NavigationView {
            VStack{
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        VStack(spacing: 24) {
                            ForEach(projectListViewModel.projectViewModels) { projectViewModel in
                                ProjectView(projectViewModel: projectViewModel, projectListViewModel: projectListViewModel)
                                    .padding([.leading, .trailing]).padding(.bottom, 12).transition(.slide).animation(.easeIn)
                            }
                        }.frame(width: geometry.size.width, height: 124.0*CGFloat(projectListViewModel.projectViewModels.count))
                    }
                }
            }
            .sheet(isPresented: $showForm) {
                NewProjectSheet(projectListViewModel: projectListViewModel)
            }
            .navigationBarTitle("My Projects")
            .navigationBarItems(leading: leadingItem,
                                trailing:
                                    Button(action: { showForm.toggle() }) {
                                        FAText(iconName: "plus", size: 26)
                                    })
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
        EmptyView()
    }
}

