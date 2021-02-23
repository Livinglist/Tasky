//
//  Avatar.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/16/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct Avatar: View, Equatable {
    static func == (lhs: Avatar, rhs: Avatar) -> Bool {
        return lhs.userId == rhs.userId && lhs.avatarService.avatarUrl?.absoluteURL == rhs.avatarService.avatarUrl?.absoluteURL
    }
    
    @ObservedObject var avatarService: AvatarService = AvatarService()
    let userId:String
    
    init(userId: String) {
        print("init Avatar")
        self.userId = userId
        avatarService.fetchAvatar(userId: userId)
    }
    
    var body: some View {
        WebImage(url: avatarService.avatarUrl)
                // Supports options and context, like `.delayPlaceholder` to show placeholder only when error
                .onSuccess { image, data, cacheType in
                }
                .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
                .placeholder(Image("placeholder")) // Placeholder Image
                .transition(.fade(duration: 0.5)) // Fade Transition with duration
                .scaledToFill()
                .background(Color.white)
                .clipShape(Circle())
            .frame(width: 40, height: 40, alignment: .center)
    }
}

struct Avatar_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
