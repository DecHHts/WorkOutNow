//
//  BodyMetric.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/29.
//

import Foundation
import SwiftData

@Model
final class BodyMetric {
    var id: UUID
    var date: Date
    var weekStartDate: Date  // Monday of the week for grouping
    var weightKg: Double?
    var heightCm: Double?
    var bodyFatPercentage: Double?
    var notes: String?

    @Relationship(deleteRule: .nullify)
    var userProfile: UserProfile?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        weightKg: Double? = nil,
        heightCm: Double? = nil,
        bodyFatPercentage: Double? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.bodyFatPercentage = bodyFatPercentage
        self.notes = notes

        // Calculate week start date (Monday)
        let calendar = Calendar.current
        self.weekStartDate = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            .date ?? date
    }
}
