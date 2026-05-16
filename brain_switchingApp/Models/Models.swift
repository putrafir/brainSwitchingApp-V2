import Foundation

enum EnergyType: String, CaseIterable {
    case logic = "Logika"
    case creative = "Kreatif"
    case physical = "Fisik"
    case admin = "Administratif"
}




enum FocusDuration: Int, CaseIterable {
    case short = 15
    case medium = 30
    case long = 60
    
    var label: String { return "\(self.rawValue) Menit" }
    var inSeconds: Int { return self.rawValue * 60 }
}

enum SessionPhase {
    case idle           // Di layar utama, memilih energi
    case durationSelect // Memilih berapa lama akan fokus
    case focusing       // Timer berjalan
    case coolingDown    // Fase Time Delay (layar terkunci)
}
