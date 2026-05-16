import SwiftUI

struct ActiveTimerView: View {
    // Mengambil data dari jalur udara
    @EnvironmentObject var sessionManager: SessionManager
    
    // Properti untuk animasi denyut (breathing effect)
    @State private var isPulsing = false
    
    // Menghitung persentase sisa waktu untuk lingkaran progress
    var progress: Double {
        if sessionManager.totalDuration == 0 { return 1.0 }
        return Double(sessionManager.timeRemaining) / Double(sessionManager.totalDuration)
    }
    
    var body: some View {
        ZStack {
            // Background Dinamis (Gradient menyesuaikan warna energi)
            LinearGradient(
                colors: [dynamicColor.opacity(0.15), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 50) {
                
                // MARK: - 2. Header Status (DI SINI PERUBAHANNYA)
                VStack(spacing: 8) {
                    // IKON DINAMIS (Berubah sesuai energi)
                    Image(systemName: dynamicIcon)
                        .font(.system(size: 32))
                        // WARNA DINAMIS (Berubah sesuai energi)
                        .foregroundColor(dynamicColor.opacity(0.8))
                    
                    Text("Sedang Fokus")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundColor(.gray)
                        .textCase(.uppercase)
                    
                    Text(sessionManager.activeEnergy?.rawValue ?? "Energi")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)
                
                // --- Sisa kode lingkaran timer (sama seperti sebelumnya) ---
                ZStack {
                    Circle().stroke(Color.white.opacity(0.05), lineWidth: 24)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AngularGradient(colors: [dynamicColor, .indigo, .cyan, dynamicColor], center: .center), style: StrokeStyle(lineWidth: 24, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .shadow(color: dynamicColor.opacity(0.4), radius: 10, x: 0, y: 0)
                        .animation(.linear(duration: 1.0), value: progress)
                    Circle()
                        .stroke(dynamicColor.opacity(0.2), lineWidth: 2)
                        .scaleEffect(isPulsing ? 1.15 : 1.0)
                        .opacity(isPulsing ? 0 : 1)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: isPulsing)
                    VStack(spacing: 0) {
                        // Menggunakan fungsi timeString dari sessionManager
                        Text(sessionManager.timeString(from: sessionManager.timeRemaining))
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .monospacedDigit()
                        Text("Tersisa")
                            .font(.system(.headline, design: .rounded)).foregroundColor(.white.opacity(0.5))
                    }
                }
                .frame(width: 300, height: 300)
                .onAppear { isPulsing = true }
                
                Spacer()
                
                // Tombol Glassmorphism
                Button(action: {
                    sessionManager.cancelSession()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("Batalkan Sesi")
                            .font(.system(.callout, design: .rounded, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Helper Functions untuk UI Dinamis
    
    // Logika untuk menentukan Ikon berdasarkan Energi yang aktif
    private var dynamicIcon: String {
        guard let energy = sessionManager.activeEnergy else { return "brain.head.profile" }
        switch energy {
        case .logic: return "brain.head.profile"
        case .creative: return "paintpalette.fill"
        case .physical: return "figure.run"
        case .admin: return "folder.fill"
        }
    }
    
    // Logika untuk menentukan Warna Utama berdasarkan Energi yang aktif
    private var dynamicColor: Color {
        guard let energy = sessionManager.activeEnergy else { return .purple }
        switch energy {
        case .logic: return .blue
        case .creative: return .purple
        case .physical: return .green
        case .admin: return .gray
        }
    }
}
