//
//  ContentView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI
import CoreData
import Firebase

struct ContentView: View {
    @ObservedObject var authService = AuthService()
    @State var userExists:Bool = false
    @State var user: User?
    
    var body: some View {
        ZStack{
            if self.user == nil {
                LoginView().transition(.slide)
            } else {
                if self.userExists {
                    ProjectListView(authService: authService).transition(.slide)
                } else {
                    EditNameView(authService: authService).transition(.slide)
                }
            }
        }.onReceive(authService.$userExists){ userExists in
            withAnimation{
                self.userExists = userExists
            }
        }.onReceive(authService.$user){ user in
            withAnimation{
                self.user = user
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
