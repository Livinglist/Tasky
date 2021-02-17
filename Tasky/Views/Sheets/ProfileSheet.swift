//
//  ProfileSheet.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/10/21.
//

import SwiftUI
import SwURL

fileprivate enum ActiveSheet: Identifiable {
    case updateNameSheet, imagePickerSheet
    
    var id: Int {
        hashValue
    }
}

struct ProfileSheet: View {
    @ObservedObject var authService: AuthService
    @ObservedObject var userService: UserService
    @ObservedObject var avatarService: AvatarService
    @State fileprivate var activeSheet: ActiveSheet?
    @State var image: Image?
    @State private var inputImage: UIImage?
    var imageSelected:Bool {
        self.inputImage != nil
    }
    
    var body: some View {
        VStack{
            Indicator().padding()
            Menu(content: {
                Button(action: { activeSheet = .imagePickerSheet }) {
                    Text("Edit")
                    Image(systemName: "pencil.circle")
                }
            }, label: {
                RemoteImageView(url: avatarService.avatarUrl ?? URL(string: "https://www.americasfinestlabels.com/images/CCS400FO.jpg")!, placeholderImage: Image("placeholder"), transition: .custom(transition: .opacity, animation: .easeOut(duration: 0.5))).imageProcessing({image in
                    return image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                }).frame(width: 160, height: 160)
            })
            Color.clear.frame(height: 24)
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
                    Image(systemName: "pencil")
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.black)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: 20, y: -12)
                        .shadow(color: Color(.black).opacity(0.6), radius: 2, x: 1, y: 1)
                }
            }
            Spacer()
        }.sheet(item: $activeSheet, onDismiss: {
            if imageSelected {
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
        print("loading image")
        guard let inputImage = inputImage else { return }
        guard let uid = authService.user?.uid else { return }
        let compressedData = inputImage.jpegData(compressionQuality: 0.5)!
        avatarService.uploadAvatar(data: compressedData, userId: uid)
        //image = Image(uiImage: inputImage)
    }
}

struct ProfileSheet_Previews: PreviewProvider {
    static var previews: some View {
        //ProfileView()
        EmptyView()
    }
}
