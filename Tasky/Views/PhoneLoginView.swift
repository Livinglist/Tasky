//
//  PhoneLoginView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/3/21.
//

import SwiftUI
import iPhoneNumberField

struct PhoneLoginView: View {
    @State var text = ""

    var body: some View {
        iPhoneNumberField(text: $text)
                    .flagHidden(false)
                    .flagSelectable(true)
                    .font(UIFont(size: 30, weight: .bold, design: .rounded))
                    .padding()
    }
}

struct PhoneLoginView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneLoginView()
    }
}
