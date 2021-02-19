//
//  AuthenticationService.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import Foundation
import Firebase

class AuthService: ObservableObject {
    @Published var user: User?
    @Published var userExists: Bool = false
    
    private var authenticationStateHandler: AuthStateDidChangeListenerHandle?
    
    var signedIn :Bool {
        return !(Auth.auth().currentUser == nil)
    }
    
    init() {
        addListeners()
        self.user = Auth.auth().currentUser
        if self.user != nil {
            self.userExists = true
        }
    }
    
    //Check whether or not the user is first time user, if not we will ask user to enter their first and last name.
    func checkUserExists(userId: String, user: User?){
        let docRef = Firestore.firestore().collection("users").document(userId)
        docRef.getDocument { (doc, error) in
            if doc?.exists ?? false {
                self.userExists = true
                self.user = user
                print("Document data: \(doc!.data()!)")
            } else {
                self.userExists = false
                self.user = user
                print("Document does not exist")
            }
        }
    }
    
    func updateUserName(firstName: String, lastName: String){
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        Firestore.firestore().collection("users").document(userId).setData(["firstName": firstName, "lastName":lastName, "id":userId])
        self.userExists = true
    }
    
    private func addListeners() {
        if let handle = authenticationStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
        authenticationStateHandler = Auth.auth()
            .addStateDidChangeListener { _, user in
                guard let uid = user?.uid else {
                    self.user = nil
                    self.userExists = false
                    return
                }
                self.checkUserExists(userId: uid, user: user)
            }
    }
}


extension AuthService{
    static var currentUser:User? { Auth.auth().currentUser }
    
    static func signIn(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult : AuthDataResult?, error : Error?) in
            
        }
    }
    
    static func signIn(verificationID: String, verificationCode:String) {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                let authError = error as NSError
                if (authError.code == AuthErrorCode.secondFactorRequired.rawValue) {
                    // The user is a multi-factor user. Second factor challenge is required.
                    let resolver = authError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    var displayNameString = ""
                    for tmpFactorInfo in (resolver.hints) {
                        displayNameString += tmpFactorInfo.displayName ?? ""
                        displayNameString += " "
                    }
                    
                } else {
                    return
                }
                return
            }
        }
        
    }
    
    static func signIn(withCredential credential: AuthCredential){
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if (error != nil) {
                // Error. If error.code == .MissingOrInvalidNonce, make sure
                // you're sending the SHA256-hashed nonce as a hex string with
                // your request to Apple.
                print(error?.localizedDescription as Any)
                return
            }
            print("signed in \(authResult?.user.displayName)")
        }
    }
    
    static func signOut() throws {
        try Auth.auth().signOut()
    }
    
    static func changeName(to name: String){
        guard let changeReq = Auth.auth().currentUser?.createProfileChangeRequest() else { return }
        changeReq.displayName = name
        changeReq.commitChanges { err in
            guard err == nil else {
                print("Failed to commit changes")
                return
            }
        }
    }
}
