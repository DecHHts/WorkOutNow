//
//  CompletionCalculator.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import Foundation
import SwiftData

class CompletionCalculator {
    /// Compare planned exercises vs actual workout
    static func calculateCompletion(
        date: Date,
        plan: TrainingPlan,
        workoutLog: WorkoutLog?,
        modelContext: ModelContext
    ) -> PlanCompletion {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        let dayNumber = PlanCalculator.cycleDay(for: targetDate, plan: plan)

        guard let template = PlanCalculator.template(for: targetDate, plan: plan) else {
            return PlanCompletion(
                date: targetDate,
                planId: plan.id,
                dayNumber: dayNumber,
                completionPercentage: 0.0
            )
        }

        // Rest day = auto-complete
        if template.isRestDay {
            return PlanCompletion(
                date: targetDate,
                planId: plan.id,
                dayNumber: dayNumber,
                completionPercentage: 1.0
            )
        }

        let plannedExerciseIds = Set(template.exercises?.compactMap { $0.exercise?.id } ?? [])

        guard !plannedExerciseIds.isEmpty else {
            return PlanCompletion(
                date: targetDate,
                planId: plan.id,
                dayNumber: dayNumber,
                completionPercentage: 0.0
            )
        }

        let completedExerciseIds = Set(workoutLog?.sets?.compactMap { $0.exercise?.id } ?? [])

        let completed = plannedExerciseIds.intersection(completedExerciseIds)
        let missed = plannedExerciseIds.subtracting(completedExerciseIds)

        let completionPercentage = Double(completed.count) / Double(plannedExerciseIds.count)

        return PlanCompletion(
            date: targetDate,
            planId: plan.id,
            dayNumber: dayNumber,
            completedExerciseIds: Array(completed),
            missedExerciseIds: Array(missed),
            completionPercentage: completionPercentage
        )
    }
}
