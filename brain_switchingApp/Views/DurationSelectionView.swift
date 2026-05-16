import SwiftUI

struct DurationSelectionView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color.black, Color.purple.opacity(0.15), Color.black], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 8) {
                    Text(sessionManager.activeEnergy?.rawValue ?? "Energi")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.purple)
                    
                    Text("Berapa Lama?")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // PILIHAN A: PRESET CEPAT
                HStack(spacing: 16) {
                    ForEach(FocusDuration.allCases, id: \.self) { duration in
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            sessionManager.isUsingCustomDuration = false
                            sessionManager.startTimer(minutes: duration.rawValue)
                        }) {
                            Text("\(duration.rawValue)\nMin")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .frame(width: 80, height: 80)
                                .background(.ultraThinMaterial)
                                .cornerRadius(20)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        }
                    }
                }
                
                Text("Atau atur waktu custom kamu:")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.gray)
                
                // PILIHAN B: SLIDER CUSTOM PREMIUM
                VStack(spacing: 16) {
                    Text("\(Int(sessionManager.customDurationInMinutes)) Menit")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(.purple)
                    
                    Slider(value: $sessionManager.customDurationInMinutes, in: 5...120, step: 5)
                        .tint(.purple)
                        .padding(.horizontal, 30)
                }
                .padding(.vertical, 20)
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Tombol Mulai Waktu Custom
                Button(action: {
                    sessionManager.startTimer(minutes: Int(sessionManager.customDurationInMinutes))
                }) {
                    Text("Mulai Fokus Custom")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
            .padding(.top, 40)
        }
        .preferredColorScheme(.dark)
    }
}
