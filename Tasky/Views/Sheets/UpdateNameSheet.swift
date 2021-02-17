//
//  UpdateNameSheet.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/15/21.
//

import SwiftUI

struct UpdateNameSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authService: AuthService
    @ObservedObject var userService: UserService
    @State var firstName:String = ""
    @State var lastName:String = ""
    
    var body: some View {
        Form{
            Section{
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
            }
            Button(action: saveChnages) {
                    Text("Save")
                      .foregroundColor(.blue)
                  }
        }.onAppear(perform: {
            firstName = userService.user?.firstName ?? ""
            lastName = userService.user?.lastName ?? ""
        })
    }
    
    func saveChnages(){
        guard !firstName.isEmpty && !lastName.isEmpty else {
            return
        }
        
        UserService.cache.removeValue(forKey: authService.user!.uid)
        
        authService.updateUserName(firstName: firstName, lastName: lastName)
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct UpdateNameSheet_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
