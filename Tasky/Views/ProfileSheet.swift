//
//  ProfileSheet.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/10/21.
//

import SwiftUI

fileprivate enum ActiveSheet: Identifiable {
    case updateNameSheet, imagePickerSheet
    
    var id: Int {
        hashValue
    }
}

struct ProfileSheet: View {
    @ObservedObject var authService: AuthService
    @ObservedObject var userService: UserService
    @State fileprivate var activeSheet: ActiveSheet?
    @State var image: Image?
    @State private var inputImage: UIImage?
    
    var body: some View {
        VStack{
            Indicator().padding()
            Menu(content: {
                Button(action: { activeSheet = .imagePickerSheet }) {
                    Text("Edit")
                    Image(systemName: "pencil.circle")
                }
            }, label: {
                Image("avatar")
                    .resizable()
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
            })
            ZStack(alignment: .topTrailing){
                HStack{
                    Text("\(self.userService.user?.firstName ?? "")")
                        .font(.title)
                    Text("\(self.userService.user?.lastName ?? "")")
                        .font(.title)
                }
                Button(action: {
                    activeSheet = .updateNameSheet
                }) {
                    Image(systemName: "pencil.circle")
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.black)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: 20, y: -12)
                        .shadow(color: Color(.black).opacity(0.8), radius: 3, x: 2, y: 2)
                }
            }
            Spacer()
        }.sheet(item: $activeSheet, onDismiss: {
            if activeSheet == .imagePickerSheet {
                loadImage()
            }
        }){ item in
            switch item {
            case .imagePickerSheet:
                ImagePicker(image: self.$inputImage)
            case .updateNameSheet:
                UpdateNameSheet(authService: authService, userService: userService)
            }
        }.onAppear(perform: {
            userService.fetchUserBy(id: authService.user?.uid ?? "")
        })
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
}

struct ProfileSheet_Previews: PreviewProvider {
    static var previews: some View {
        //ProfileView()
        EmptyView()
    }
}
