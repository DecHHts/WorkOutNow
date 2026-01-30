//
//  ExerciseDetailView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Query private var workoutSets: [WorkoutSet]
    @Environment(LocalizationManager.self) private var localization

    init(exercise: Exercise) {
        self.exercise = exercise
        let exerciseId = exercise.id
        _workoutSets = Query(
            filter: #Predicate<WorkoutSet> { set in
                set.exercise?.id == exerciseId
            },
            sort: \WorkoutSet.completedAt,
            order: .reverse
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.displayName(language: localization.language))
                        .font(.title)
                        .fontWeight(.bold)
                    MuscleGroupBadge(muscleGroup: exercise.muscleGroup)
                }
                .padding()

                if exercise.videoURLYouTube != nil || exercise.videoURLBilibili != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(localization.text(english: "Video Tutorials", chinese: "视频教程"))
                            .font(.headline)
                            .padding(.horizontal)

                        VideoLinksSection(
                            youtubeURL: exercise.videoURLYouTube,
                            bilibiliURL: exercise.videoURLBilibili
                        )
                        .padding(.horizontal)
                    }
                }

                if exercise.isCustom {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(localization.text(english: "Default Settings", chinese: "默认设置"))
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            if let sets = exercise.defaultSets {
                                HStack {
                                    Text(localization.text(english: "Sets", chinese: "组数"))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(sets)")
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal)
                            }

                            if let reps = exercise.defaultReps {
                                HStack {
                                    Text(localization.text(english: "Reps", chinese: "次数"))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(reps)")
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal)
                            }

                            if let rest = exercise.defaultRestSeconds {
                                HStack {
                                    Text(localization.text(english: "Rest", chinese: "休息时间"))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(rest)s")
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }

                if !workoutSets.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(localization.text(english: "Workout History", chinese: "训练历史"))
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(workoutSets.prefix(10)) { set in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(set.completedAt, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(localization.text(english: "Set \(set.setNumber)", chinese: "第\(set.setNumber)组"))
                                        .font(.subheadline)
                                }

                                Spacer()

                                if let weight = set.weightKg {
                                    Text("\(String(format: "%.1f", weight)) kg")
                                        .fontWeight(.semibold)
                                }

                                Text("× \(set.reps)")
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}
