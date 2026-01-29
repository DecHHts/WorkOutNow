//
//  UserProfile.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/29.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var appleUserID: String
    var email: String?
    var fullName: String?
    var birthday: Date?
    var gender: Gender
    var heightCm: Double?
    var weightKg: Double?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \BodyMetric.userProfile)
    var bodyMetrics: [BodyMetric]?

    init(
        id: UUID = UUID(),
        appleUserID: String,
        email: String? = nil,
        fullName: String? = nil,
        birthday: Date? = nil,
        gender: Gender = .preferNotToSay,
        heightCm: Double? = nil,
        weightKg: Double? = nil
    ) {
        self.id = id
        self.appleUserID = appleUserID
        self.email = email
        self.fullName = fullName
        self.birthday = birthday
        self.gender = gender
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    case preferNotToSay = "Prefer not to say"

    var chineseName: String {
        switch self {
        case .male: return "男"
        case .female: return "女"
        case .other: return "其他"
        case .preferNotToSay: return "不透露"
        }
    }
}
