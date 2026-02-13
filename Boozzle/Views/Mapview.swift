import SwiftUI

struct MapView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: UpgradeVM
    
    private let purple = Color(red: 0x41/255, green: 0x23/255, blue: 0x5C/255)
    private let orange = Color(red: 0xC2/255, green: 0x4D/255, blue: 0x32/255)
    private let lockBgColor = Color(red: 0xA9/255, green: 0x3A/255, blue: 0x4E/255)
    
    let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [purple, orange], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("back")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .shadow(radius: 2)
                            .contentShape(Rectangle())
                    }
                    Spacer()
                }
                .padding()
                .padding(.top, 20)
                
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 0) {
                    if vm.unlockedRooms.contains(.livingRoom) {
                        NavigationLink(destination: RoomView(roomType: .livingRoom)) {
                            RoomCell(imageName: "room_living", isLocked: false, lockColor: lockBgColor)
                        }
                    } else {
                        RoomCell(imageName: "room_living", isLocked: true, lockColor: lockBgColor)
                    }
                    
                    if vm.unlockedRooms.contains(.bedroom) {
                        NavigationLink(destination: RoomView(roomType: .bedroom)) {
                            RoomCell(imageName: "room_bedroom", isLocked: false, lockColor: lockBgColor)
                        }
                    } else {
                        RoomCell(imageName: "room_bedroom", isLocked: true, lockColor: lockBgColor)
                    }
                    
                    RoomCell(imageName: "room_hallway", isLocked: true, lockColor: lockBgColor)
                    RoomCell(imageName: "room_kitchen", isLocked: true, lockColor: lockBgColor)
                }
                .frame(maxHeight: .infinity)
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct RoomCell: View {
    let imageName: String
    let isLocked: Bool
    let lockColor: Color
    
    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .aspectRatio(0.8, contentMode: .fill)
                .clipped()
            
            if isLocked {
                ZStack {
                    Color.black.opacity(0.4)
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(lockColor)
                            .frame(width: 70, height: 70)
                            .shadow(radius: 4)
                        
                        Image("lock_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                }
            }
        }
        .contentShape(Rectangle())
    }
}
