//
//  NewTagSheet.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/19/21.
//

import SwiftUI

struct NewTagSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var projectViewModel: ProjectViewModel
    @State var label: String = ""
    @State var colorString: String = "Blue"
    
    var body: some View {
        NavigationView{
            Form{
                TextField("Tag label", text: $label)
                Picker(selection: $colorString, label: Text("Tag color"), content: {
                    Color("Black").frame(width: 24, height: 24).tag("Black")
                    Color("Blue").frame(width: 24, height: 24).tag("Blue")
                    Color("Gray").frame(width: 24, height: 24).tag("Gray")
                    Color("Green").frame(width: 24, height: 24).tag("Green")
                    Color("Indigo").frame(width: 24, height: 24).tag("Indigo")
                    Color("Pink").frame(width: 24, height: 24).tag("Pink")
                    Color("Purple").frame(width: 24, height: 24).tag("Purple")
                    Color("Red").frame(width: 24, height: 24).tag("Red")
                    Color("Teal").frame(width: 24, height: 24).tag("Teal")
                    Color("Yellow").frame(width: 24, height: 24).tag("Yellow")
                })
                Button(action: addTag, label: {
                    Text("Add tag")
                })
            }.navigationBarTitle("").navigationBarHidden(true)
            
        }
        
    }
    
    func addTag(){
        projectViewModel.addTag(label: label, colorString: colorString)
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewTagSheet_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}