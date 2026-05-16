//
//  TimeDelay.swift
//  brain_switchingApp
//
//  Created by MacBook on 12/05/25.
//

import SwiftUI

struct TimeDelayView: View {
    let from: String
    let to: String
    
    var body: some View {
        HStack(alignment: .center) {
            Text("Time Delay")
                .font(.caption)
                .foregroundColor(Color("Purple"))
            VStack(alignment: .leading, spacing: 6) {
    
                HStack {
                    Circle()
                        .fill(Color("Purple"))
                        .frame(width: 6, height: 6)
                    Rectangle()
                        .fill(Color("Purple"))
                        .frame(height: 1)
                    Text("\(from) - \(to)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Rectangle()
                        .fill(Color("Purple"))
                        .frame(height: 1)
                }
            }
        }
    }
}
