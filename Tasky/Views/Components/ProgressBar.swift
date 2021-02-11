//
//  ProgressBar.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/5/21.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var value: Float
    var color: Color = Color(.orange)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(color)
                    .animation(.linear)
            }.cornerRadius(45.0)
        }
    }
}
