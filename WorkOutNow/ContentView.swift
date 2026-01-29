//
//  ContentView.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        TabView {
            WorkoutCalendarView()
                .tabItem {
                    Label(localization.text(english: "Workout", chinese: "训练"), systemImage: "calendar")
                }

            PlanCalendarView()
                .tabItem {
                    Label(localization.text(english: "Plan", chinese: "计划"), systemImage: "calendar.badge.checkmark")
                }

            ExerciseDatabaseView()
                .tabItem {
                    Label(localization.text(english: "Exercises", chinese: "动作库"), systemImage: "figure.strengthtraining.traditional")
                }

            TrainingPlansView()
                .tabItem {
                    Label(localization.text(english: "Plans", chinese: "训练计划"), systemImage: "list.bullet.clipboard")
                }

            SettingsView()
                .tabItem {
                    Label(localization.text(english: "Settings", chinese: "设置"), systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
