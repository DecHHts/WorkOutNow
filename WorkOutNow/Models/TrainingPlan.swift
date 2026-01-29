//
//  TrainingPlan.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import Foundation
import SwiftData

@Model
final class TrainingPlan {
    var id: UUID
    var name: String
    var cycleDays: Int // Flexible: 3, 6, 7, etc.
    var startDate: Date
    var isActive: Bool

    @Relationship(deleteRule: .cascade, inverse: \DayTemplate.plan)
    var dayTemplates: [DayTemplate]?

    init(
        id: UUID = UUID(),
        name: String,
        cycleDays: Int,
        startDate: Date = Date(),
        isActive: Bool = false
    ) {
        self.id = id
        self.name = name
        self.cycleDays = cycleDays
        self.startDate = startDate
        self.isActive = isActive
    }
}

@Model
final class DayTemplate {
    var id: UUID
    var dayNumber: Int // 1-indexed
    var name: String? // "Chest + Triceps"
    var isRestDay: Bool

    @Relationship(deleteRule: .nullify)
    var plan: TrainingPlan?

    @Relationship(deleteRule: .cascade, inverse: \PlanExercise.dayTemplate)
    var exercises: [PlanExercise]?

    init(
        id: UUID = UUID(),
        dayNumber: Int,
        name: String? = nil,
        isRestDay: Bool = false
    ) {
        self.id = id
        self.dayNumber = dayNumber
        self.name = name
        self.isRestDay = isRestDay
    }
}

@Model
final class PlanExercise {
    var id: UUID
    var order: Int
    var targetSets: Int
    var targetReps: Int
    var restSeconds: Int

    @Relationship(deleteRule: .nullify)
    var exercise: Exercise?

    @Relationship(deleteRule: .nullify)
    var dayTemplate: DayTemplate?

    init(
        id: UUID = UUID(),
        order: Int,
        targetSets: Int = 3,
        targetReps: Int = 10,
        restSeconds: Int = 90
    ) {
        self.id = id
        self.order = order
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.restSeconds = restSeconds
    }
}
