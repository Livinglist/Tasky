//
//  LoginView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI
import CryptoKit
import FirebaseAuth
import FASwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var currentNonce:String?
    @State var showPhoneLoginSheet: Bool = false
    
    //Hashing function using CryptoKit
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView{
            VStack{
                Image(uiImage: getAppIcon()).resizable().scaledToFit().frame(width: 120, height: 120).cornerRadius(26).shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                Color.clear.frame(height: 36)
                Button(action: { showPhoneLoginSheet.toggle() }){
                    HStack{
                        FAText(iconName: "phone", size: 14).foregroundColor(.white)
                        Text("Sign in with Phone").foregroundColor(.white)
                    }.frame(width: 280, height: 45, alignment: .center).background(Color(.orange)).overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.blue, lineWidth: 0))
                }.cornerRadius(6.0).padding(.bottom, 6)
//                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/){
//                    HStack{
//                        FAText(iconName: "google", size: 14).foregroundColor(.white)
//                        Text("Sign in with Gmail").foregroundColor(.white)
//                    }.frame(width: 280, height: 45, alignment: .center).background(Color(.systemBlue)).overlay(
//                        RoundedRectangle(cornerRadius: 0)
//                            .stroke(Color.blue, lineWidth: 0))
//                }.cornerRadius(6.0).disabled(true)
                SignInWithAppleButton(
                    //Request
                    onRequest: { request in
                        let nonce = randomNonceString()
                        currentNonce = nonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = sha256(nonce)
                    },
                    
                    //Completion
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            
                            switch authResults.credential {
                            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                
                                guard let nonce = currentNonce else {
                                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                }
                                guard let appleIDToken = appleIDCredential.identityToken else {
                                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                }
                                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                                    return
                                }
                                
                                let firstName = appleIDCredential.fullName?.givenName
                                let lastName = appleIDCredential.fullName?.familyName
                                
                                UserDefaults.standard.setValue(firstName, forKey: "firstName")
                                UserDefaults.standard.setValue(lastName, forKey: "lastName")
                                
                                let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
                                
                                AuthService.signIn(withCredential: credential)
                                
                                print("\(String(describing: Auth.auth().currentUser?.uid))")
                            default:
                                break
                                
                            }
                        default:
                            break
                        }
                        
                    }
                ).frame(width: 280, height: 45, alignment: .center).signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                
            }
        }.sheet(isPresented: $showPhoneLoginSheet){
            PhoneLoginView()
        }
    }
    
    
    func getAppIcon() -> UIImage {
       var appIcon: UIImage! {
         guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
         let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
         let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
         let lastIcon = iconFiles.last else { return nil }
         return UIImage(named: lastIcon)
       }
      return appIcon
    }
    
    struct LoginView_Previews: PreviewProvider {
        static var previews: some View {
            LoginView()
        }
    }
}
