//
//  PeopleSheet.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/16/21.
//

import SwiftUI
import SPAlert


struct PeopleListView: View, Equatable{
    static func == (lhs: PeopleListView, rhs: PeopleListView) -> Bool {
        lhs.users == rhs.users
    }
    
    let users: [TaskyUser]
    let onPressed: (TaskyUser)->()
    
    var body: some View {
        List{
            ForEach(users) { user in
                HStack{
                    Avatar(userId: user.id)
                    Text("\(user.firstName) \(user.lastName)")
                    Spacer()
                    Button(action: {
                        onPressed(user)
                    }, label: {
                        Image(systemName: "plus.circle").font(.system(size: 24)).foregroundColor(.blue)
                    })
                }
            }
        }
    }
}

struct PeopleSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var projectViewModel: ProjectViewModel
    @ObservedObject var userService: UserService = UserService()
    @State var showAlert: Bool = false
    @State var selectedUser: TaskyUser = TaskyUser(id: "", firstName: "", lastName: "")
    @State var text: String = ""
    @State private var isEditing = false
    
    var body: some View {
        VStack{
            HStack {
                TextField("Search ...", text: $text).onChange(of: text, perform: { val in
                    userService.searchUserBy(name: text)
                })
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        if isEditing {
                            Button(action: {
                                self.text = ""
                                
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
                
                if isEditing {
                    Button(action: {
                        self.isEditing = false
                        self.text = ""
                        
                        // Dismiss the keyboard
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Text("Cancel")
                    }
                    .padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
                    .animation(.default)
                }
            }.padding()
            
            PeopleListView(users: userService.resultUsers, onPressed: { user in
                selectedUser = user
                showAlert.toggle()
            }).equatable()
            
        }.alert(isPresented: $showAlert, content: {
            Alert(title: Text("Add \(selectedUser.fullName) as collaborator?"), message: Text(""), primaryButton: .default(Text("Cancel")), secondaryButton: .default(Text("Yes"), action: {
                self.projectViewModel.addCollaborator(userId: selectedUser.id)
                SPAlert.present(title: "Added to Project", preset: .done, haptic: .success)
                presentationMode.wrappedValue.dismiss()
            }))
        })
    }
}

struct PeopleSheet_Previews: PreviewProvider {
    static var previews: some View {
        //PeopleSheet()
        EmptyView()
    }
}
