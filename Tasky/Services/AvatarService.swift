//
//  AvatarService.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/15/21.
//

import Foundation
import Firebase
import FirebaseStorage

class AvatarService: ObservableObject {
    @Published var avatarUrl: URL?
    
    func fetchAvatar(userId: String){
        if AvatarService.cache.keys.contains(userId) {
            self.avatarUrl = AvatarService.cache[userId]!
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()

        // Child references can also take paths delimited by '/'
        // spaceRef now points to "images/space.jpg"
        // imagesRef still points to "images"
        let spaceRef = storageRef.child("images/\(userId).jpg")
        
        
        spaceRef.downloadURL { url , err in
            guard let downloadURL = url else {
                print(err!.localizedDescription)
                UserDefaults.standard.setValue(true, forKey: "AvatarUpdated")
                AvatarService.cache[userId] = URL(string: "https://avatars.dicebear.com/4.5/api/jdenticon/\(userId).svg")!
                self.avatarUrl = AvatarService.cache[userId]
                return
            }
            
            UserDefaults.standard.setValue(true, forKey: "AvatarUpdated")
            AvatarService.cache[userId] = downloadURL.absoluteURL
            self.avatarUrl = downloadURL.absoluteURL
        }
    }
    
    func uploadAvatar(data: Data, userId: String){
        let storage = Storage.storage()
        let storageRef = storage.reference()

        // Child references can also take paths delimited by '/'
        // spaceRef now points to "images/space.jpg"
        // imagesRef still points to "images"
        let spaceRef = storageRef.child("images/\(userId).jpg")
        
        spaceRef.putData(data, metadata: nil) { (metadata, err) in
            spaceRef.downloadURL { url, err in
                guard let downloadURL = url else {
                    print(err!.localizedDescription)
                    AvatarService.cache[userId] = URL(string: "https://avatars.dicebear.com/4.5/api/jdenticon/\(userId).svg")!
                    self.avatarUrl = AvatarService.cache[userId]
                    return
                }
                
                AvatarService.cache[userId] = downloadURL.absoluteURL
                self.avatarUrl = downloadURL.absoluteURL
            }
        }
    }
    
    func deleteAvatar(userId: String){
        let storage = Storage.storage()
        let storageRef = storage.reference()

        // Child references can also take paths delimited by '/'
        // spaceRef now points to "images/space.jpg"
        // imagesRef still points to "images"
        let spaceRef = storageRef.child("images/\(userId).jpg")
        
        spaceRef.delete { err in
            if let err = err {
                print("\(err.localizedDescription)")
                return
            }
            
            AvatarService.cache[userId] = URL(string: "https://avatars.dicebear.com/4.5/api/jdenticon/\(userId).svg")!
            self.avatarUrl = AvatarService.cache[userId]
        }
    }
}

extension AvatarService{
    static var cache: [String: URL] = [:]
}
