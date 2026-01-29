//
//  PlanCalculator.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import Foundation

class PlanCalculator {
    /// Calculate which day of cycle for any date
    /// Formula: (days since start % cycleDays) + 1
    static func cycleDay(for date: Date, plan: TrainingPlan) -> Int {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: plan.startDate)
        let targetDay = calendar.startOfDay(for: date)

        guard targetDay >= startDay else { return 0 }

        let days = calendar.dateComponents([.day], from: startDay, to: targetDay).day ?? 0
        return (days % plan.cycleDays) + 1
    }

    /// Get template for specific date
    static func template(for date: Date, plan: TrainingPlan) -> DayTemplate? {
        let day = cycleDay(for: date, plan: plan)
        guard day > 0 else { return nil }
        return plan.dayTemplates?.first { $0.dayNumber == day }
    }
}
