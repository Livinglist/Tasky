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
    
    private var authenticationStateHandler: AuthStateDidChangeListenerHandle?
    
    var signedIn :Bool {
        return !(Auth.auth().currentUser == nil)
    }
    
    init() {
        addListeners()
    }
    
    static func signIn(withEmail email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult : AuthDataResult?, error : Error?) in
            
        }

        //    if Auth.auth().currentUser == nil {
        //      Auth.auth().signInAnonymously()
        //    }
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
            // ...
            return
          }
          // User is signed in
          // ...
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
            print("signed in")
        }
    }
    
    static func signOut() throws {
        try Auth.auth().signOut()
    }
    
    private func addListeners() {
        if let handle = authenticationStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
        authenticationStateHandler = Auth.auth()
            .addStateDidChangeListener { _, user in
                self.user = user
            }
    }
}
