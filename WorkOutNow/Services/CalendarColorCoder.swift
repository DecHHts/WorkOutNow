//
//  CalendarColorCoder.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import Foundation
import SwiftUI

enum CalendarDayStatus {
    case future // Gray
    case completedFull // Green
    case completedPartial(percentage: Double) // Yellow/Orange
    case missed // Red
    case restDay // Blue
}

class CalendarColorCoder {
    static func status(for date: Date, plan: TrainingPlan?, completion: PlanCompletion?) -> CalendarDayStatus {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)

        if targetDate > today {
            return .future
        }

        guard let plan = plan else {
            return .future
        }

        // Dates BEFORE plan creation → gray (not red!)
        let planStartDate = calendar.startOfDay(for: plan.startDate)
        if targetDate < planStartDate {
            return .future
        }

        if let template = PlanCalculator.template(for: date, plan: plan), template.isRestDay {
            return .restDay
        }

        guard let completion = completion else {
            return .missed
        }

        if completion.completionPercentage >= 1.0 {
            return .completedFull
        } else if completion.completionPercentage > 0 {
            return .completedPartial(percentage: completion.completionPercentage)
        } else {
            return .missed
        }
    }

    static func color(for status: CalendarDayStatus) -> Color {
        switch status {
        case .future:
            return .gray.opacity(0.3)
        case .completedFull:
            return .green
        case .completedPartial(let percentage):
            return percentage > 0.5 ? .yellow : .orange
        case .missed:
            return .red
        case .restDay:
            return .blue.opacity(0.5)
        }
    }
}
