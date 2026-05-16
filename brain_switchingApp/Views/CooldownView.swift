import SwiftUI

struct CooldownView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        ZStack {
            // Background Rileks
            LinearGradient(colors: [Color.black, Color.green.opacity(0.1), Color.black], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Status Atas
                VStack(spacing: 6) {
                    Text("FASE COOLDOWN")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundColor(.green)
                        .tracking(2)
                    
                    Text("Waktunya Istirahat")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 30)
                
                // Timer Istirahat Bulat Kecil
              
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.05), lineWidth: 8)
                                    Circle()
                                        .stroke(Color.green, lineWidth: 8)
                                        .shadow(color: .green.opacity(0.3), radius: 5)
                                    
                                    // GANTI BAGIAN INI:
                                    Text(sessionManager.timeString(from: sessionManager.timeRemaining))
                                        .font(.system(.title, design: .monospaced, weight: .bold))
                                        .foregroundColor(.white)
                                        .monospacedDigit() // Tambahan agar teks angka tidak bergeser/goyang saat detiknya berubah
                                }
                                .frame(width: 140, height: 140)
                
                // --- FITUR UTAMA: KOTAK REKOMENDASI BRAIN SWITCHING ---
                VStack(alignment: .leading, spacing: 16) {
                    Text("REKOMENDASI SWITCHING:")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                    
                    Text("Kamu baru saja menyelesaikan sesi \(sessionManager.lastCompletedEnergy?.rawValue ?? "Fokus") Kerja bagus! Untuk menyegarkan otak kembali, yuk switch ke energi ini selanjutnya:")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .leadingAlignment()
                    
                    // Daftar Energi yang Direkomendasikan Sistem
                    HStack(spacing: 12) {
                        ForEach(sessionManager.getSwitchingRecommendations(), id: \.self) { recommendedEnergy in
                            Button(action: {
                                // Otomatis pilih energi rekomendasi dan pindah ke pemilihan durasi
                                sessionManager.selectEnergy(recommendedEnergy)
                                sessionManager.currentPhase = .durationSelect
                            }) {
                                HStack {
                                    Text(recommendedEnergy.rawValue)
                                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                            }
                        }
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Tombol Selesai Istirahat Lebih Cepat
                Button(action: {
                    sessionManager.cancelSession() // Kembali ke Menu Utama (.idle)
                }) {
                    Text("Lewati Istirahat")
                        .font(.system(.callout, design: .rounded, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Helper kecil agar text alignment rapi ke kiri
extension View {
    func leadingAlignment() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
    }
}
