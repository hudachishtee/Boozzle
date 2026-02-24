import SwiftUI
import SwiftData

@main
struct BoozzleApp: App {
    @StateObject private var upgradeVM = UpgradeVM()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(upgradeVM)
        }
        .modelContainer(for: [PlayerSave.self, ItemSave.self])
    }
}
