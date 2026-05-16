//
//  TaskCardView.swift
//  brain_switchingApp
//
//  Created by MacBook on 12/05/25.
//

import SwiftUI

//struct TaskItem {
//    let time: String
//    let title: String
//    let subtitle: String
//    let color: Color
//}

struct TaskCardView: View {
    let jadwal: Jadwal
    @State private var showDetailPopup = false
    @Binding var daftarJadwal: [Jadwal]
    let onJadwalAdded: () -> Void
    private func toggleCompletion() {
        if let index = daftarJadwal.firstIndex(where: { $0.id == jadwal.id }) {
            daftarJadwal[index].isCompleted.toggle()
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack{
                Text(jadwal.waktuMulai.formatted(.dateTime.hour().minute()))
                    .font(.subheadline)
                    .frame(width: 50, alignment: .leading)
                    .foregroundColor(jadwal.isCompleted ? .gray : .gray)
                Spacer()
                Text(jadwal.waktuSelesai.formatted(.dateTime.hour().minute()))
                    .font(.subheadline)
                    .frame(width: 50, alignment: .leading)
                    .foregroundColor(jadwal.isCompleted ? .gray : .gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(jadwal.namaJadwal)
                        .font(.subheadline)
                        .bold()
                        .strikethrough(jadwal.isCompleted)
                        .foregroundColor(jadwal.isCompleted ? .gray : .black)
                    
                    Spacer()
                    
                    // Checkmark button
                    Button(action: toggleCompletion) {
                        Image(systemName: jadwal.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(jadwal.isCompleted ? .green : .gray)
                    }
                }
                
                HStack{
                    Text(jadwal.tipe)
                        .foregroundColor(jadwal.isCompleted ? .gray : (jadwal.tipe == "Kerja" ? Color.red : Color.blue))
                    
                    Text("Detail")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .onTapGesture {
                            showDetailPopup = true
                        }
                }
            }
            .padding()
            .background(jadwal.isCompleted ? Color.gray.opacity(0.1) : Color(.white))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showDetailPopup) {
            ModalView(jadwaldiklik: jadwal, parentDaftarJadwal: $daftarJadwal, onJadwalAdded:onJadwalAdded)
        }
    }
    
    struct ModalView: View {
        @Environment(\.dismiss) private var dismiss
        @State private var showEditSheet = false
        let jadwaldiklik: Jadwal
        @Binding var parentDaftarJadwal: [Jadwal]
        let onJadwalAdded: () -> Void
        
        private var dateString: String {
            let fmt = DateFormatter()
            fmt.dateFormat = "EEEE, MMM d, yyyy"
            return fmt.string(from: jadwaldiklik.tanggal)
        }
        private var startString: String {
            let fmt = DateFormatter()
            fmt.dateFormat = "HH:mm:ss"
            return fmt.string(from: jadwaldiklik.waktuMulai)
        }
        private var endString: String {
            let fmt = DateFormatter()
            fmt.dateFormat = "HH:mm:ss"
            return fmt.string(from: jadwaldiklik.waktuSelesai)
        }
        
        var body: some View {
            NavigationStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(jadwaldiklik.namaJadwal)
                            .bold()
                            .font(.title2)
                            .strikethrough(jadwaldiklik.isCompleted)
                            .foregroundColor(jadwaldiklik.isCompleted ? .gray : .black)
                        
                        Spacer()
                        
                        // Checkmark button in modal
                        Button(action: {
                            if let index = parentDaftarJadwal.firstIndex(where: { $0.id == jadwaldiklik.id }) {
                                parentDaftarJadwal[index].isCompleted.toggle()
                            }
                        }) {
                            Image(systemName: jadwaldiklik.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(jadwaldiklik.isCompleted ? .green : .gray)
                                .imageScale(.large)
                        }
                    }
                    
                    Text("\(dateString)").font(.body)
                    Text("\(startString) -\(endString)").font(.body)
                    
                    Spacer()
                    
                    Text(jadwaldiklik.tipe)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(jadwaldiklik.isCompleted ? Color.gray : jadwaldiklik.tipe == "Kerja" ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .padding()
                .background(.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .frame(width: 340, height: 180)
                .navigationTitle("Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                        .foregroundColor(Color("Purple"))
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") {
                            showEditSheet = true
                        }
                        .foregroundColor(Color("Purple"))
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                AddJadwalView(
                    showSheet: $showEditSheet,
                    daftarJadwal: $parentDaftarJadwal,
                    selectedDate: jadwaldiklik.tanggal,
                    isEditMode: true,
                    editingJadwal: jadwaldiklik,
                    onJadwalAdded: onJadwalAdded
                )
                .presentationDetents([.fraction(0.5), .medium])
            }
        }
    }
}
