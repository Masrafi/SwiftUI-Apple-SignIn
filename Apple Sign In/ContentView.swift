import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") private var logStatus: Bool = false
    var body: some View {
        if logStatus {
            Home()
        } else {
            LogIn()
        }
    }
}
