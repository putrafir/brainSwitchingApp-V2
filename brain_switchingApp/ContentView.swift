import SwiftUI
import UserNotifications

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
    
    func isWithinTimeRange(of targetDate: Date, rangeInSeconds: TimeInterval) -> Bool {
        let timeDifference = self.timeIntervalSince(targetDate)
        return timeDifference >= 0 && timeDifference <= rangeInSeconds
    }
}

struct ContentView: View {
    
    @State private var selectedDate: Date = {
       
        let calendar = Calendar.current
        let now = Date()
        return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now) ?? now
    }()
    @State private var currentMonthOffset = 0
    @State private var showAddSheet = false
    @State private var daftarJadwal: [Jadwal] = []
    @State private var showRestReminder = false
    @State private var scheduledNotifications: Set<Date> = []

    var body: some View {
        VStack(spacing: 0) {
            CalendarHeader(selectedDate: $selectedDate, currentMonthOffset: $currentMonthOffset, daftarJadwal: daftarJadwal)
                .padding(.vertical)
            
            Divider()
            
       
          
            ZStack {
                Color("Gray").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            Text("Schedule")
                                .font(.title3)
                                .bold()
                            
                            Spacer()
                            
                            Button(action: {
                                showAddSheet = true
                            }) {
                                Text("Add").foregroundColor(Color("Purple"))
                            }
                        }
                        .padding(.top, 16)
                        .sheet(isPresented: $showAddSheet) {
                            AddJadwalView(
                                showSheet: $showAddSheet,
                                daftarJadwal: $daftarJadwal,
                                selectedDate: selectedDate,
                                isEditMode: false,
                                onJadwalAdded: {
                                          checkForRestReminder()
                                          startTimer()
                                      }
                            )
                            .presentationDetents([.fraction(0.5), .medium])
                        }
                        
                        let daftarJadwalSelected = daftarJadwal
                            .filter { $0.tanggal.isSameDay(as: selectedDate) }
                        
                        if daftarJadwalSelected.isEmpty {
                            HStack{
                                Spacer()
                                VStack(spacing: 16) {
                                    Image("illustrasi")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 250, height: 250)
                                        .opacity(0.8)

                                    Text("Tidak ada jadwal")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)

                                    Text("Kamu belum memiliki jadwal pada tanggal ini.")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                }
                                .padding(.top, 40)
                                
                                Spacer()
                            }
                        }
 else {
                            let sortedJadwal = daftarJadwalSelected.sorted { $0.waktuMulai < $1.waktuMulai }

                            ForEach(Array(sortedJadwal.enumerated()), id: \.1.id) { index, jadwal in
                                if index > 0 {
                                    let prev = sortedJadwal[index - 1]
                                    let timeGap = jadwal.waktuMulai.timeIntervalSince(prev.waktuSelesai)
                                    
                                    if jadwal.tipe != prev.tipe && timeGap < 3600 {
                                        TimeDelayView(
                                            from: prev.waktuSelesai.formatted(date: .omitted, time: .shortened),
                                            to: jadwal.waktuMulai.formatted(date: .omitted, time: .shortened)
                                        )
                                    }
                                }
                                TaskCardView(jadwal: jadwal, daftarJadwal: $daftarJadwal,onJadwalAdded: {
                                    checkForRestReminder()
                                    startTimer()
                                })
                            }
                        }
                    }
                    .padding(.horizontal)
                }

            }
        }
        .onAppear {
  
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Izin notifikasi diberikan")
                } else {
                    print("Izin notifikasi ditolak")
                }
            }
            
            UNUserNotificationCenter.current().delegate = notificationDelegate
            
            checkForRestReminder()
            startTimer()
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            checkForRestReminder()
        }
    }

   

    private func checkForRestReminder() {
        let sortedJadwal = daftarJadwal
            .filter { $0.tanggal.isSameDay(as: selectedDate) }
            .sorted { $0.waktuMulai < $1.waktuMulai }

        guard sortedJadwal.count >= 2 else { return }

        for index in 1..<sortedJadwal.count {
            let prev = sortedJadwal[index - 1]
            let current = sortedJadwal[index]
            let timeGap = current.waktuMulai.timeIntervalSince(prev.waktuSelesai)

     
            if current.tipe != prev.tipe && timeGap < 3600 {
                let triggerTime = Calendar.current.date(bySetting: .second, value: 0, of: prev.waktuSelesai) ?? prev.waktuSelesai

                if triggerTime > Date() && !scheduledNotifications.contains(triggerTime) {
                    scheduledNotifications.insert(triggerTime)
                    scheduleRestNotification(at: triggerTime)
                }
            }
        }
    }

}



#Preview {
    ContentView()
}
