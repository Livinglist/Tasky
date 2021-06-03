//
//  FirestoreService.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/9/21.


import Foundation
import Firebase

class UserService: ObservableObject {
    @Published var userName: String?
    @Published var user: TaskyUser?
    @Published var resultUsers: [TaskyUser] = []
    
    func fetchUserBy(id: String){
        if let user = UserService.cache[id] {
            self.user = user
            return
        }
        
        Firestore.firestore().collection("users").document(id).getDocument { (docSnapshot, err) in
            if let err = err {
                print("Error fetching user \(id), error: \(err.localizedDescription)")
                return
            }
            
            self.user = try? docSnapshot?.data(as: TaskyUser.self)
            
            guard let user = self.user else { return }
            
            self.userName = user.firstName + " " + user.lastName
            UserService.cache[id] = user
        }
    }
    
    func fetchUsersBy(ids: [String]){
        self.resultUsers.removeAll()
        
        for id in ids {
            if let user = UserService.cache[id] {
                self.resultUsers.append(user)
                continue
            }
            
            Firestore.firestore().collection("users").document(id).getDocument { (docSnapshot, err) in
                if let err = err {
                    print("Error fetching user \(id), error: \(err.localizedDescription)")
                    return
                }
                
                let u = try? docSnapshot?.data(as: TaskyUser.self)
                
                guard let user = u else { return }
                
                print("appending \(user)")
                self.resultUsers.append(user)
                
                UserService.cache[id] = user
            }
        }
    }
    
    func searchUserBy(name: String){
        if name.isEmpty { return }
        
        resultUsers.removeAll()
        
        let splitStr = name.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: false)
        let firstName = splitStr[0]
        let lastName = splitStr.count > 1 ? splitStr[1] : ""
        
        print("Searching for \(firstName), the name is \(name) \(splitStr)")
        
        var firstNameTokens:[String] = []
        
        for i in 0..<firstName.count{
            let str = String(firstName.prefix(i+1))
            firstNameTokens.append(str)
        }
        
        Firestore.firestore().collection("users").whereField("firstName", in: firstNameTokens).getDocuments { (snapshots, err) in
            if let err = err {
                print("Error searching user using name: \(name) \(err)")
                return
            }
            
            if let snapshots = snapshots {
                for doc in snapshots.documents {
                    guard let user = try? doc.data(as: TaskyUser.self) else { continue }
                    
                    self.resultUsers.append(user)
                }
            }
        }
        
        if !lastName.isEmpty {
            var lastNameTokens:[String] = []
            
            for i in 0..<firstName.count{
                let str = String(lastName.prefix(i+1))
                lastNameTokens.append(str)
            }
            
            Firestore.firestore().collection("users").whereField("lastName", in: lastNameTokens).getDocuments { (snapshots, err) in
                if let err = err {
                    print("Error searching user using name: \(name) \(err)")
                    return
                }
                
                if let snapshots = snapshots {
                    for doc in snapshots.documents {
                        guard let user = try? doc.data(as: TaskyUser.self) else { continue }
                        
                        if !self.resultUsers.contains(user){
                            self.resultUsers.append(user)
                        }
                    }
                }
            }
        }
    }
}

extension UserService{
    static var cache: [String: TaskyUser] = [:]
}
