//
//  ContentView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var authService = AuthService()
    var body: some View {
        if self.authService.user == nil {
            LoginView()
        } else {
            ProjectListView(authService: authService)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
