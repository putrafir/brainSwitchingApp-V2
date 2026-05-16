import SwiftUI
import Combine
import UserNotifications
import ActivityKit
import Foundation

class SessionManager: ObservableObject {
    // MARK: - 1. Properties (State Data)
    @Published var currentPhase: SessionPhase = .idle
    @Published var activeEnergy: EnergyType? = nil
    @Published var timeRemaining: Int = 0
    @Published var totalDuration: Int = 0
    
    // Fitur Custom Waktu
    @Published var isUsingCustomDuration: Bool = false
    @Published var customDurationInMinutes: Double = 25.0 // Default 25 menit
    
    // Fitur Brain Switching
    @Published var lastCompletedEnergy: EnergyType? = nil
    
    // Variabel internal untuk sistem (tidak perlu @Published)
    private var currentActivity: Activity<TimerAttributes>?
    private var timerSubscription: AnyCancellable?
    
    // MARK: - 2. Core Actions (Alur Aplikasi)
    
    // Langkah 1: Pilih Energi
    func selectEnergy(_ energy: EnergyType) {
        self.activeEnergy = energy
        self.currentPhase = .durationSelect
    }
    
    // Langkah 2: Mulai Timer (Mendukung preset & custom)
    func startTimer(minutes: Int) {
        let durationInSeconds = minutes * 60
        self.timeRemaining = durationInSeconds
        self.totalDuration = durationInSeconds
        self.currentPhase = .focusing
        
        // Mulai sistem background
        requestNotificationPermission()
        scheduleLocalNotification(title: "Waktu Habis!", body: "Saatnya mendinginkan otakmu sejenak.", in: durationInSeconds)
        runTimer()
        startLiveActivity(phase: "Fokus", durationInSeconds: durationInSeconds)
    }
    
    // Langkah 3: Eksekusi Timer
    private func runTimer() {
        timerSubscription?.cancel()
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.handleTimerCompletion()
                }
            }
    }
    
    // Langkah 4: Pergantian Fase saat Waktu Habis
    private func handleTimerCompletion() {
        timerSubscription?.cancel()
        
        if currentPhase == .focusing {
            triggerCooldown()
        } else if currentPhase == .coolingDown {
            finishCycle()
        }
    }
    
    // Langkah 5: Masuk Fase Cooldown (Brain Switching Aktif)
    private func triggerCooldown() {
        // Simpan energi yang baru saja diselesaikan untuk dianalisis
        self.lastCompletedEnergy = self.activeEnergy
        
        self.currentPhase = .coolingDown
        // Hitung waktu istirahat (misal: 20% dari waktu kerja)
        let cooldownSeconds = Int(Double(totalDuration) * 0.2)
        self.timeRemaining = cooldownSeconds
        self.totalDuration = cooldownSeconds
        
        scheduleLocalNotification(title: "Pendinginan Selesai", body: "Otakmu sudah segar. Pilih energi baru!", in: cooldownSeconds)
        runTimer()
        updateLiveActivity(phase: "Cooling Down", durationInSeconds: cooldownSeconds)
    }
    
    // Langkah 6: Selesai Istirahat, Kembali ke Awal
    func finishCycle() {
        timerSubscription?.cancel()
        self.activeEnergy = nil
        self.currentPhase = .idle
        endLiveActivity()
    }
    
    // Batalkan Sesi Paksa (Tombol Stop)
    func cancelSession() {
        timerSubscription?.cancel()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        self.activeEnergy = nil
        self.currentPhase = .idle
        endLiveActivity()
    }
    
    // MARK: - 3. Helper Functions
    
    // Fungsi pintar rekomendasi energi
    func getSwitchingRecommendations() -> [EnergyType] {
        guard let lastEnergy = lastCompletedEnergy else { return [.creative, .physical] }
        
        switch lastEnergy {
        case .logic: return [.creative, .physical]
        case .creative: return [.logic, .admin]
        case .physical: return [.admin, .logic]
        case .admin: return [.creative, .physical]
        }
    }
    
    // Formatter waktu ("25:00")
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    // MARK: - 4. Notifications Logic
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    private func scheduleLocalNotification(title: String, body: String, in seconds: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
        
    // MARK: - 5. Live Activities Logic
    private func startLiveActivity(phase: String, durationInSeconds: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let endTime = Date().addingTimeInterval(TimeInterval(durationInSeconds))
        let attributes = TimerAttributes(energyName: activeEnergy?.rawValue ?? "Fokus")
        let contentState = TimerAttributes.ContentState(endTime: endTime, phaseName: phase)
        let activityContent = ActivityContent(state: contentState, staleDate: nil)
        
        do {
            currentActivity = try Activity.request(attributes: attributes, content: activityContent)
        } catch {
            print("❌ Gagal memulai Live Activity: \(error.localizedDescription)")
        }
    }
    
    private func updateLiveActivity(phase: String, durationInSeconds: Int) {
        guard let activity = currentActivity else { return }
        let endTime = Date().addingTimeInterval(TimeInterval(durationInSeconds))
        let updatedState = TimerAttributes.ContentState(endTime: endTime, phaseName: phase)
        let activityContent = ActivityContent(state: updatedState, staleDate: nil)
        
        Task { await activity.update(activityContent) }
    }
    
    private func endLiveActivity() {
        guard let activity = currentActivity else { return }
        let finalState = TimerAttributes.ContentState(endTime: Date(), phaseName: "Selesai")
        let activityContent = ActivityContent(state: finalState, staleDate: nil)
        
        Task { await activity.end(activityContent, dismissalPolicy: .immediate) }
    }
}
