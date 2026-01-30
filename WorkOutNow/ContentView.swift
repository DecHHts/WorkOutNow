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
    @Environment(ThemeManager.self) private var themeManager

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

            NutritionCalendarView()
                .tabItem {
                    Label(localization.text(english: "Nutrition", chinese: "营养"), systemImage: "fork.knife")
                }

            BodyMetricsDashboardView()
                .tabItem {
                    Label(localization.text(english: "Body", chinese: "身体"), systemImage: "figure.arms.open")
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
        .background(themeManager.theme.backgroundColor.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
