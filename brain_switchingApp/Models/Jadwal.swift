//
//  Jadwal.swift
//  brain_switchingApp
//
//  Created by MacBook on 12/05/25.
//
import SwiftUI

struct Jadwal: Identifiable {
    let id = UUID()
    var namaJadwal: String
    var tanggal: Date
    var waktuMulai: Date
    var waktuSelesai: Date
    var tipe: String
    var isCompleted: Bool = false
 
}
