////
////  CalendarHeaderView.swift
////  brain_switchingApp
////
////  Created by MacBook on 12/05/25.
////
//
//import SwiftUI
//struct CalendarHeader: View {
//    @Binding var selectedDate: Date
//    @Binding var currentMonthOffset: Int
//    let daftarJadwal: [Jadwal]  // Add this to access schedules
//
//    var days: [String] { ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] }
//    
//    private func getScheduleCount(for date: Date) -> Int {
//        return daftarJadwal.filter { Calendar.current.isDate($0.tanggal, inSameDayAs: date) }.count
//    }
//
//    var body: some View {
//        let calendar = Calendar.current
//        let displayedMonth = calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
//        let daysInMonth = generateDaysInMonth(for: displayedMonth)
//
//        VStack(spacing: 8) {
//            HStack {
//                Button(action: {
//                    currentMonthOffset -= 1
//                }) {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(Color("Purple"))
//                }
//                
//                Spacer()
//
//                Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
//                    .font(.title3)
//                    .bold()
//
//                Spacer()
//
//                Button(action: {
//                    currentMonthOffset += 1
//                }) {
//                    Image(systemName: "chevron.right")
//                        .foregroundColor(Color("Purple"))
//                }
//            }
//            .padding(.horizontal)
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 8) {
//                    ForEach(daysInMonth, id: \.self) { date in
//                        VStack(spacing: 8) {
//                            Text(dayName(for: date))
//                                .font(.caption2)
//
//                            ZStack {
//                                Text("\(calendar.component(.day, from: date))")
//                                    .font(.body)
//                                    .fontWeight(.medium)
//                                    .frame(width: 32, height: 32)
//                                    .background(calendar.isDate(date, inSameDayAs: selectedDate) ? Color("Purple") : Color.clear)
//                                    .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? .white : .primary)
//                                    .clipShape(Circle())
//                                
//                                let scheduleCount = getScheduleCount(for: date)
//                                if scheduleCount > 0 {
//                                    Text("\(scheduleCount)")
//                                        .font(.caption2)
//                                        .foregroundColor(.white)
//                                        .frame(width: 16, height: 16)
//                                        .background(Color.red)
//                                        .clipShape(Circle())
//                                        .offset(x: 12, y: -12)
//                                }
//                            }
//                            .onTapGesture {
//                                let calendar = Calendar.current
//                                if let fixedDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date) {
//                                    selectedDate = fixedDate
//                                }
//                            }
//                        }
//                    }
//                }
//                .padding(.horizontal)
//            }
//            .padding(.top, 20)
//        }
//    }
//
//    func dayName(for date: Date) -> String {
//        let weekday = Calendar.current.component(.weekday, from: date)
//        return days[(weekday + 5) % 7]
//    }
//
//    func generateDaysInMonth(for date: Date) -> [Date] {
//        let calendar = Calendar.current
//        guard let range = calendar.range(of: .day, in: .month, for: date),
//              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
//            return []
//        }
//
//        return range.compactMap { day -> Date? in
//            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
//        }
//    }
//}


//
//  CalendarHeaderView.swift
//  brain_switchingApp
//
//  Created by MacBook on 12/05/25.
//

import SwiftUI

struct CalendarHeader: View {
    @Binding var selectedDate: Date
    @Binding var currentMonthOffset: Int
    let daftarJadwal: [Jadwal]

    var days: [String] { ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] }
    
    private func getScheduleCount(for date: Date) -> Int {
        return daftarJadwal.filter { Calendar.current.isDate($0.tanggal, inSameDayAs: date) }.count
    }

    var body: some View {
        let calendar = Calendar.current
        let displayedMonth = calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
        let daysInMonth = generateDaysInMonth(for: displayedMonth)

        VStack(spacing: 8) {
            HStack {
                Button(action: {
                    currentMonthOffset -= 1
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("Purple"))
                }
                
                Spacer()

                Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.title3)
                    .bold()

                Spacer()

                Button(action: {
                    currentMonthOffset += 1
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color("Purple"))
                }
            }
            .padding(.horizontal)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(daysInMonth, id: \.self) { date in
                            VStack(spacing: 8) {
                                Text(dayName(for: date))
                                    .font(.caption2)

                                ZStack {
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .frame(width: 32, height: 32)
                                        .background(calendar.isDate(date, inSameDayAs: selectedDate) ? Color("Purple") : Color.clear)
                                        .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? .white : .primary)
                                        .clipShape(Circle())
                                    
                                    let scheduleCount = getScheduleCount(for: date)
                                    if scheduleCount > 0 {
                                        Text("\(scheduleCount)")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .frame(width: 16, height: 16)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .offset(x: 12, y: -12)
                                    }
                                }
                                .onTapGesture {
                                    if let fixedDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date) {
                                        selectedDate = fixedDate
                                    }
                                }
                            }
                            .id(date) // ID untuk ScrollViewReader
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    DispatchQueue.main.async {
                        // Scroll otomatis ke tanggal hari ini
                        if let todayInMonth = daysInMonth.first(where: { calendar.isDateInToday($0) }) {
                            proxy.scrollTo(todayInMonth, anchor: .center)
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
    }

    func dayName(for date: Date) -> String {
        let weekday = Calendar.current.component(.weekday, from: date)
        return days[(weekday + 5) % 7]
    }

    func generateDaysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }
    }
}
