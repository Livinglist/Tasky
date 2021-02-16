//
//  PhoneLoginView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/3/21.
//

import SwiftUI
import iPhoneNumberField
import FirebaseAuth

struct PhoneLoginView: View {
    @State var phoneNumber = ""
    @State var verificationCode = ""
    @State var reqestSent: Bool = false
    
    var body: some View {
        if reqestSent {
            Form{
                TextField("6-Digit Code", text: $verificationCode).keyboardType(.numberPad).onReceive( verificationCode.publisher.collect()) {
                    self.verificationCode = String($0.prefix(6))
                }
                
                Button(action: {
                    guard !verificationCode.isEmpty else { return }
                    
                    let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                    let credential = PhoneAuthProvider.provider().credential(
                        withVerificationID: verificationID!,
                        verificationCode: verificationCode)
                    AuthService.signIn(withCredential: credential)
                }, label: {
                    Text("Sign in")
                })
            }
        }else {
            iPhoneNumberField(text: $phoneNumber)
                .maximumDigits(10)
                .prefixHidden(false)
                .flagHidden(true)
                .flagSelectable(false)
                .font(UIFont(size: 30, weight: .bold, design: .rounded))
                .padding()
            Button(action: {
                print("the phone number is \(phoneNumber)")
                phoneNumber = "+1" + phoneNumber.trimmingCharacters(in: ["(", ")","-"])
                print("the phone number is \(phoneNumber)")
                reqestSent.toggle()
                PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    // Sign in using the verificationID and the code sent to the user
                    // ...
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                }
                
            }, label: {
                Text("Continue")
            })
        }
    }
}

struct PhoneLoginView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneLoginView()
    }
}
