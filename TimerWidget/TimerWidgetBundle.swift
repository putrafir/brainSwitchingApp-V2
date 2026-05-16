//
//  TimerWidgetBundle.swift
//  TimerWidget
//
//  Created by Ahmad putra firdaus on 16/05/26.
//

import WidgetKit
import SwiftUI

@main
struct TimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimerWidget()
        TimerWidgetLiveActivity()
    }
}
