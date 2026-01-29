//
//  PlanCompletion.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import Foundation
import SwiftData

@Model
final class PlanCompletion {
    var id: UUID
    var date: Date
    var planId: UUID
    var dayNumber: Int
    var completedExerciseIds: [UUID]
    var missedExerciseIds: [UUID]
    var completionPercentage: Double // 0.0-1.0

    init(
        id: UUID = UUID(),
        date: Date,
        planId: UUID,
        dayNumber: Int,
        completedExerciseIds: [UUID] = [],
        missedExerciseIds: [UUID] = [],
        completionPercentage: Double = 0.0
    ) {
        self.id = id
        self.date = date
        self.planId = planId
        self.dayNumber = dayNumber
        self.completedExerciseIds = completedExerciseIds
        self.missedExerciseIds = missedExerciseIds
        self.completionPercentage = completionPercentage
    }
}
