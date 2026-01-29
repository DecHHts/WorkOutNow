//
//  MuscleGroupBadge.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI

struct MuscleGroupBadge: View {
    let muscleGroup: MuscleGroup
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        Text(localization.muscleGroupName(muscleGroup))
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(muscleGroupColor.opacity(0.2))
            .foregroundStyle(muscleGroupColor)
            .cornerRadius(8)
    }

    private var muscleGroupColor: Color {
        switch muscleGroup {
        case .chest: return .red
        case .back: return .blue
        case .shoulders: return .orange
        case .biceps: return .purple
        case .triceps: return .pink
        case .legs: return .green
        case .core: return .yellow
        case .cardio: return .cyan
        case .fullBody: return .indigo
        }
    }
}
