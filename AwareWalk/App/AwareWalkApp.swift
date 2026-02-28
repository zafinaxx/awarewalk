import SwiftUI

@main
struct AwareWalkApp: App {
    @State private var appState = AppState()
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .task {
                    await appState.subscriptionManager.loadProducts()
                    await appState.subscriptionManager.restorePurchases()
                    Task { await appState.subscriptionManager.listenForTransactions() }
                }
        }
        .windowStyle(.plain)
        .defaultSize(width: 1400, height: 900)

        WindowGroup(id: "theme-gallery") {
            ThemeGalleryView()
                .environment(appState)
        }
        .defaultSize(width: 900, height: 700)

        WindowGroup(id: "settings") {
            SettingsView()
                .environment(appState)
        }
        .defaultSize(width: 500, height: 600)

        ImmersiveSpace(id: "hud-space") {
            ImmersiveHUDView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed)
    }
}
