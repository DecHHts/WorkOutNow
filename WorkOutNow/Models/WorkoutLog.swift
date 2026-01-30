//
//  WorkoutLog.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import Foundation
import SwiftData

@Model
final class WorkoutLog {
    var id: UUID
    var date: Date
    var duration: TimeInterval?
    var notes: String?
    var intensityRating: Int? // 1-10
    var caloriesBurned: Double? // 消耗的热量（千卡）

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.workoutLog)
    var sets: [WorkoutSet]?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval? = nil,
        notes: String? = nil,
        intensityRating: Int? = nil,
        caloriesBurned: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.notes = notes
        self.intensityRating = intensityRating
        self.caloriesBurned = caloriesBurned
    }
}

@Model
final class WorkoutSet {
    var id: UUID
    var setNumber: Int
    var reps: Int
    var weightKg: Double?
    var restSeconds: Int?
    var completedAt: Date

    @Relationship(deleteRule: .nullify)
    var exercise: Exercise?

    @Relationship(deleteRule: .nullify)
    var workoutLog: WorkoutLog?

    init(
        id: UUID = UUID(),
        setNumber: Int,
        reps: Int,
        weightKg: Double? = nil,
        restSeconds: Int? = nil,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.setNumber = setNumber
        self.reps = reps
        self.weightKg = weightKg
        self.restSeconds = restSeconds
        self.completedAt = completedAt
    }
}
