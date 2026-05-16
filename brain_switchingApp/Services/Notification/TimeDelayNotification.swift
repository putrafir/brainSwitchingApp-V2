//
//  TimeDelayNotification.swift
//  brain_switchingApp
//
//  Created by MacBook on 15/05/25.
//

import Foundation
import UserNotifications



let notificationDelegate = NotificationDelegate()

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}


func scheduleRestNotification(at date: Date) {
    let content = UNMutableNotificationContent()
    content.title = "Waktunya Istirahat"
    content.body = "Kamu waktunya time delay. Yuk istirahat sebentar!"
    content.sound = .default

    let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Gagal menjadwalkan notifikasi: \(error.localizedDescription)")
        } else {
            print("Notifikasi istirahat dijadwalkan untuk: \(date)")
                       printPendingNotifications()
        }
    }
}


func printPendingNotifications() {
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        print("Daftar Notifikasi yang Sedang Dijadwalkan:")
        for request in requests {
            if let trigger = request.trigger as? UNCalendarNotificationTrigger,
               let nextTriggerDate = trigger.nextTriggerDate() {
                print("ID: \(request.identifier) | Trigger: \(nextTriggerDate)")
            } else {
                print("ID: \(request.identifier) | Tanpa trigger tanggal yang diketahui.")
            }
        }
    }
}


