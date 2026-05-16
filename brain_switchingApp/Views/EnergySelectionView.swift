import SwiftUI

struct EnergySelectionView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    // Konfigurasi Grid: 2 Kolom yang fleksibel
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            // MARK: - 1. Background Gradient
            LinearGradient(
                colors: [Color.black, Color.indigo.opacity(0.2), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - 2. Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Theorem One")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundColor(.purple)
                            .textCase(.uppercase)
                            .tracking(2)
                        
                        Text("Pilih Energi Kamu")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Sesuaikan suasana hati dengan aktivitas yang akan kamu lakukan.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 20)
                    
                    // MARK: - 3. Grid Kartu Energi
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(EnergyType.allCases, id: \.self) { energy in
                            EnergyCard(energy: energy) {
                                // Haptic feedback saat memilih
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    sessionManager.selectEnergy(energy)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Komponen Kartu Energi Premium
struct EnergyCard: View {
    let energy: EnergyType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Ikon dengan Gradasi
                Image(systemName: iconForEnergy(energy))
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical) // Efek layer ikon Apple
                    .foregroundColor(colorForEnergy(energy))
                    .frame(width: 50, height: 50)
                    .background(colorForEnergy(energy).opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(energy.rawValue)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(descriptionForEnergy(energy))
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .frame(height: 180)
            .frame(maxWidth: .infinity, alignment: .leading)
            // Efek Kaca (Glassmorphism)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            // Garis tepi tipis agar terlihat tajam
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(SquishButtonStyle()) // Animasi menekan yang memuaskan
    }
    
    // Helper untuk Ikon
    // Ubah nama case (misal: .focus menjadi .fokus) di KETIGA fungsi ini
    // MARK: - Helper untuk Ikon
        func iconForEnergy(_ type: EnergyType) -> String {
            switch type {
            case .logic: return "brain.head.profile"
            case .creative: return "paintpalette.fill"
            case .physical: return "figure.run"
            case .admin: return "folder.fill"
            }
        }
        
        // MARK: - Helper untuk Warna
        func colorForEnergy(_ type: EnergyType) -> Color {
            switch type {
            case .logic: return .blue
            case .creative: return .purple
            case .physical: return .green
            case .admin: return .yellow
            }
        }
        
        // MARK: - Helper untuk Deskripsi Singkat
        func descriptionForEnergy(_ type: EnergyType) -> String {
            switch type {
            case .logic: return "Analisis & Pemecahan Masalah"
            case .creative: return "Imajinasi & Ide Baru"
            case .physical: return "Aktivitas & Gerakan"
            case .admin: return "Kerapian & Dokumen"
            }
        }
}

// MARK: - Animasi Tombol Khas Apple (Squish Effect)
struct SquishButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
