import SwiftUI
import SwiftData // ✅

@main
struct BoozzleApp: App {
    @StateObject private var upgradeVM = UpgradeVM()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(upgradeVM)
        }
        // ✅ Official SwiftData Registration
        .modelContainer(for: [PlayerSave.self, ItemSave.self])
    }
}
