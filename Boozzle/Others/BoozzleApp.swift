import SwiftUI

@main
struct BoozzleApp: App {
    // We create the "Brain" here once
    @StateObject private var upgradeVM = UpgradeVM()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(upgradeVM) // Pass it to all views
        }
    }
}
