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
        print("fetching avatar")
        let storage = Storage.storage()
        let storageRef = storage.reference()

        // Child references can also take paths delimited by '/'
        // spaceRef now points to "images/space.jpg"
        // imagesRef still points to "images"
        let spaceRef = storageRef.child("images/\(userId).jpg")
        
        
        spaceRef.downloadURL { url , err in
            guard let downloadURL = url else {
                print(err!.localizedDescription)
                return
            }
            
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
                    return
                }
                
                self.avatarUrl = downloadURL.absoluteURL
            }
        }
    }
}
