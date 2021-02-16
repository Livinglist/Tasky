//
//  UserDetailSheet.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/10/21.
//

import SwiftUI

struct EditNameView: View {
    @ObservedObject var authService: AuthService
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
        }
    }
    
    func saveChnages(){
        guard !firstName.isEmpty && !lastName.isEmpty else {
            return
        }
        
        authService.updateUserName(firstName: firstName, lastName: lastName)
    }
}

struct UserDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        //UserDetailSheet()
        Text("")
    }
}
