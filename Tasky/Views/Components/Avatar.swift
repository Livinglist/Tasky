//
//  Avatar.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/16/21.
//

import SwiftUI
import SwURL

struct Avatar: View {
    @ObservedObject var avatarService: AvatarService = AvatarService()
    let userId:String
    
    init(userId: String) {
        self.userId = userId
    }
    
    var body: some View {
        RemoteImageView(url: avatarService.avatarUrl ?? URL(string: "https://www.americasfinestlabels.com/images/CCS400FO.jpg")!, placeholderImage: Image("placeholder"), transition: .custom(transition: .opacity, animation: .easeOut(duration: 0.5))).imageProcessing({image in
            return image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        }).frame(width: 40, height: 40).onAppear(perform: {
            avatarService.fetchAvatar(userId: self.userId)
        })
    }
}

struct Avatar_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
