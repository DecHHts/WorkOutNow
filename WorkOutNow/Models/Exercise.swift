//
//  Exercise.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var nameEnglish: String
    var nameChinese: String
    var muscleGroup: MuscleGroup
    var isCustom: Bool
    var videoURLYouTube: String?
    var videoURLBilibili: String?

    // Custom exercise defaults
    var defaultSets: Int?
    var defaultReps: Int?
    var defaultRestSeconds: Int?

    @Relationship(deleteRule: .nullify, inverse: \WorkoutSet.exercise)
    var workoutSets: [WorkoutSet]?

    @Relationship(deleteRule: .nullify, inverse: \PlanExercise.exercise)
    var planExercises: [PlanExercise]?

    init(
        id: UUID = UUID(),
        nameEnglish: String,
        nameChinese: String,
        muscleGroup: MuscleGroup,
        isCustom: Bool = false,
        videoURLYouTube: String? = nil,
        videoURLBilibili: String? = nil,
        defaultSets: Int? = nil,
        defaultReps: Int? = nil,
        defaultRestSeconds: Int? = nil
    ) {
        self.id = id
        self.nameEnglish = nameEnglish
        self.nameChinese = nameChinese
        self.muscleGroup = muscleGroup
        self.isCustom = isCustom
        self.videoURLYouTube = videoURLYouTube
        self.videoURLBilibili = videoURLBilibili
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.defaultRestSeconds = defaultRestSeconds
    }
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case legs = "Legs"
    case core = "Core"
    case cardio = "Cardio"
    case fullBody = "Full Body"

    var chineseName: String {
        switch self {
        case .chest: return "胸部"
        case .back: return "背部"
        case .shoulders: return "肩部"
        case .biceps: return "二头肌"
        case .triceps: return "三头肌"
        case .legs: return "腿部"
        case .core: return "核心"
        case .cardio: return "有氧"
        case .fullBody: return "全身"
        }
    }
}

extension Exercise {
    func displayName(language: AppLanguage) -> String {
        language == .chinese ? nameChinese : nameEnglish
    }
}
