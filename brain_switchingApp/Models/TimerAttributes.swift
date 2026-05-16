import Foundation
import ActivityKit

struct TimerAttributes: ActivityAttributes {
    // State dinamis (Bisa berubah di tengah jalan, misal: sisa waktu)
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var phaseName: String // "Sedang Fokus" atau "Time Delay"
    }
    
    // State statis (Tidak berubah selama aktivitas berjalan)
    var energyName: String // Kategori yang dipilih, misal: "🎨 Kreatif"
}
