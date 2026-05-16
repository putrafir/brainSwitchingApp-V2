import SwiftUI

struct ContentView: View {
    // Menghubungkan ViewModel State Machine kita
    @StateObject private var sessionManager = SessionManager()
    
    var body: some View {
        ZStack {
            // Background color dinamis berdasarkan fase
            backgroundColor
                .ignoresSafeArea()
            
            // Routing tampilan berdasarkan State
            // Routing tampilan berdasarkan State
                        switch sessionManager.currentPhase {
                        case .idle:
                            EnergySelectionView()
                        case .durationSelect:
                            DurationSelectionView()
                        case .focusing:
                            ActiveTimerView()
                        case .coolingDown:
                            CooldownView()
                        }
        }
        // Inject SessionManager ke seluruh child views (ini tetap dipertahankan)
        .environmentObject(sessionManager)
    }
    
    private var backgroundColor: Color {
        switch sessionManager.currentPhase {
        case .idle, .durationSelect:
            return Color("AppGray") // Pastikan warnanya sama dengan di Assets
        case .focusing:
            return Color.black.opacity(0.85) // Mode gelap untuk fokus
        case .coolingDown:
            return Color("AppPurple").opacity(0.2) // Warna rileks
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
