import SwiftUI

@main
struct brain_switchingAppApp: App {
    @StateObject private var sessionManager = SessionManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
