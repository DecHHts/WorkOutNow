//
//  WorkOutNowApp.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/26.
//

import SwiftUI
import SwiftData

@main
struct WorkOutNowApp: App {
    @AppStorage("hasSeededExercises") private var hasSeededExercises = false

    // Initialize managers
    @State private var localizationManager = LocalizationManager()
    @State private var themeManager = ThemeManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            WorkoutLog.self,
            WorkoutSet.self,
            TrainingPlan.self,
            DayTemplate.self,
            PlanExercise.self,
            PlanCompletion.self,
            UserProfile.self,
            BodyMetric.self
        ])

        // Simple configuration that works reliably
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("❌ ModelContainer error: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if !hasSeededExercises {
                        ExerciseSeeder.seedExercises(modelContext: sharedModelContainer.mainContext)
                        hasSeededExercises = true
                    }
                }
                .preferredColorScheme(themeManager.theme.colorScheme)
                .tint(themeManager.theme.primaryColor)
        }
        .modelContainer(sharedModelContainer)
        .environment(localizationManager)
        .environment(themeManager)
    }
}
