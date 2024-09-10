import SwiftUI
import FirebaseCore

@main
struct Apple_Sign_InApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
