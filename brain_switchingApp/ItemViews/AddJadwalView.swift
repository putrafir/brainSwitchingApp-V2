//
//  AddJadwalView.swift
//  brain_switchingApp
//
//  Created by MacBook on 12/05/25.
//
import SwiftUI

struct AddJadwalView: View {
    @Binding var showSheet: Bool
    @Binding var daftarJadwal: [Jadwal]
    var onJadwalAdded: () -> Void
    @State var showAllert = false {
        didSet {
            print("showAllert = \(showAllert)")
        }
    }
   
    @State private var showTimeError = false
    var selectedDate: Date
    var isEditMode: Bool
    var editingJadwal: Jadwal?
    
    @State private var namaJadwal: String
    @State private var waktuMulai: Date
    @State private var waktuSelesai: Date
    @State private var tipe: String
    @State private var alertMessage = ""
    
    let tipeJadwal = ["Kerja", "Belajar"]
    
    private var waktuMulaiRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: selectedDate)!
        return startOfDay...endOfDay
    }
    
    private var waktuSelesaiRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: selectedDate)!
        return waktuMulai...endOfDay
    }
    
    init(showSheet: Binding<Bool>, daftarJadwal: Binding<[Jadwal]>, selectedDate: Date, isEditMode: Bool = false, editingJadwal: Jadwal? = nil, onJadwalAdded:@escaping () -> Void) {
        _showSheet = showSheet
        _daftarJadwal = daftarJadwal
        self.selectedDate = selectedDate
        self.isEditMode = isEditMode
        self.editingJadwal = editingJadwal
        self.onJadwalAdded = onJadwalAdded 
        
        // Initialize state variables
        if let jadwal = editingJadwal {
            // Edit mode
            _namaJadwal = State(initialValue: jadwal.namaJadwal)
            _waktuMulai = State(initialValue: jadwal.waktuMulai)
            _waktuSelesai = State(initialValue: jadwal.waktuSelesai)
            _tipe = State(initialValue: jadwal.tipe)
        } else {
            // Add mode
            _namaJadwal = State(initialValue: "")
            let calendar = Calendar.current
            let now = Date()
            let startOfDay = calendar.startOfDay(for: selectedDate)
            
            // Jika tanggal yang dipilih adalah hari ini, gunakan waktu sekarang
            // Jika bukan, gunakan awal hari
            let initialTime = calendar.isDateInToday(selectedDate) ? now : startOfDay
            _waktuMulai = State(initialValue: initialTime)
            
            // Set waktu selesai 1 jam setelah waktu mulai
            _waktuSelesai = State(initialValue: calendar.date(byAdding: .hour, value: 1, to: initialTime) ?? initialTime)
            _tipe = State(initialValue: "Kerja")
        }
    }
    
    private func isValidTimeRange() -> Bool {
        return waktuSelesai > waktuMulai
    }
    
    private func validateTimes() -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: waktuMulai, to: waktuSelesai)
        if let minutes = components.minute, minutes <= 0 {
            alertMessage = "Waktu selesai harus lebih besar dari waktu mulai"
            showAllert = true
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Nama Pekerjaan", text: $namaJadwal)
                DatePicker("Waktu Mulai",
                          selection: $waktuMulai,
                          in: waktuMulaiRange,
                          displayedComponents: .hourAndMinute)
                    .onChange(of: waktuMulai) { newValue in
                        let calendar = Calendar.current
                        // Update waktu selesai agar minimal 1 jam setelah waktu mulai
                        waktuSelesai = calendar.date(byAdding: .hour, value: 1, to: newValue) ?? newValue
                    }
                
                DatePicker("Waktu Selesai",
                          selection: $waktuSelesai,
                          in: waktuSelesaiRange,
                          displayedComponents: .hourAndMinute)
                
                Picker("Tipe Jadwal", selection: $tipe) {
                    ForEach(tipeJadwal, id: \.self) { tipe in
                        Text(tipe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Button(action: {
                    // Validasi waktu terlebih dahulu
                    guard validateTimes() else { return }
                    
                    if isEditMode, let editingJadwal = editingJadwal,
                       let index = daftarJadwal.firstIndex(where: { $0.id == editingJadwal.id }) {
                        // Edit mode - update existing jadwal
                        var jadwal = daftarJadwal[index]
                        jadwal.namaJadwal = namaJadwal
                        jadwal.waktuMulai = waktuMulai
                        jadwal.waktuSelesai = waktuSelesai
                        jadwal.tipe = tipe
                        daftarJadwal[index] = jadwal
                        showSheet = false
                        onJadwalAdded()
                    } else {
                        // Add mode - check for conflicts
                        let jadwalBaru = Jadwal(
                            namaJadwal: namaJadwal,
                            tanggal: selectedDate,
                            waktuMulai: waktuMulai,
                            waktuSelesai: waktuSelesai,
                            tipe: tipe
                        )
                        
                        var hasConflict = false
                        for jadwalCheck in daftarJadwal {
                            if cekJadwalCrush(timeStart: jadwalCheck.waktuMulai, timeEnd: jadwalCheck.waktuSelesai, timeInput: waktuMulai) ||
                                cekJadwalCrush(timeStart: jadwalCheck.waktuMulai, timeEnd: jadwalCheck.waktuSelesai, timeInput: waktuSelesai) {
                                hasConflict = true
                                alertMessage = "Jadwal bentrok"
                                showAllert = true
                                break
                            }
                        }
                        
                        if !hasConflict {
                            daftarJadwal.append(jadwalBaru)
                            showSheet = false
                            onJadwalAdded()
                        }
                    }
                }) {
                    Text(isEditMode ? "Update Jadwal" : "Simpan Jadwal")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("Purple"))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
                .alert(isPresented: $showAllert) {
                    Alert(
                        title: Text(alertMessage),
                        message: Text("Cek Kembali Jadwal Anda"),
                        dismissButton: .default(Text("OK")) {
                            showAllert = false
                        }
                    )
                }
            }
            .navigationTitle(isEditMode ? "Edit Jadwal" : "Tambah Jadwal")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func isDateInRange(startDate: Date, endDate: Date, checkDate: Date) -> Bool {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd HH:mm"
        let startDateChange = dateFormater.string(from: startDate)
        let endDateChange = dateFormater.string(from: endDate)
        let checkDateChange = dateFormater.string(from: checkDate)
        let newCheckDate = dateFormater.date(from: checkDateChange)!
        let newStartDate = dateFormater.date(from: startDateChange)!
        let newEndDate = dateFormater.date(from: endDateChange)!
        print("Tanggal Setelah dirubah \(startDateChange) ")
        return newCheckDate >= newStartDate && newCheckDate <= newEndDate
    }
    func cekJadwalCrush(timeStart: Date,timeEnd: Date, timeInput: Date) -> Bool{
            // Check if the checkDate is between startDate and endDate
        if isDateInRange(startDate: timeStart, endDate: timeEnd, checkDate: timeInput) {
                print("Tanggal dan waktu berada di antara range start : \(timeStart) time end \(timeEnd) time ceck \(timeInput)")
                return true
            } else {
                print("Tanggal dan waktu tidak berada di antara range time satrt : \(timeStart) time end \(timeEnd) time ceck \(timeInput)")
                return false
            }

        
    }
    

}

