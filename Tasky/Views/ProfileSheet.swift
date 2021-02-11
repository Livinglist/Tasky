//
//  ProfileView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/10/21.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authService: AuthService

    var body: some View {
        VStack{
            Indicator().padding()
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        //ProfileView()
        EmptyView()
    }
}
