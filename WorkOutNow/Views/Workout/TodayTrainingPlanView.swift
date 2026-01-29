//
//  TodayTrainingPlanView.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/29.
//

import SwiftUI
import SwiftData

struct TodayTrainingPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization
    @Query(filter: #Predicate<TrainingPlan> { $0.isActive }) private var activePlans: [TrainingPlan]

    let date: Date
    @Binding var showingLogWorkout: Bool

    private var activePlan: TrainingPlan? {
        activePlans.first
    }

    private var todayTemplate: DayTemplate? {
        guard let plan = activePlan else { return nil }
        return PlanCalculator.template(for: date, plan: plan)
    }

    private var plannedExercises: [PlanExercise] {
        todayTemplate?.exercises?.sorted { $0.order < $1.order } ?? []
    }

    private var isRestDay: Bool {
        todayTemplate?.isRestDay ?? false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localization.text(english: "Today's Plan", chinese: "今日训练计划"))
                        .font(.headline)
                    if let plan = activePlan, let template = todayTemplate {
                        Text(template.name ?? localization.text(
                            english: "Day \(PlanCalculator.cycleDay(for: date, plan: plan))",
                            chinese: "第\(PlanCalculator.cycleDay(for: date, plan: plan))天"
                        ))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if !plannedExercises.isEmpty {
                    Button(action: {
                        showingLogWorkout = true
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text(localization.text(english: "Start", chinese: "开始"))
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)

            // 内容
            if activePlan == nil {
                // 没有激活的计划
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text(localization.text(english: "No active training plan", chinese: "暂无激活的训练计划"))
                        .foregroundStyle(.secondary)
                    NavigationLink(destination: Text("Plans")) {
                        Text(localization.text(english: "Create a plan", chinese: "创建计划"))
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()

            } else if isRestDay {
                // 休息日
                VStack(spacing: 12) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                    Text(localization.text(english: "Rest Day", chinese: "休息日"))
                        .font(.headline)
                    Text(localization.text(english: "Recovery is important!", chinese: "恢复同样重要！"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()

            } else if plannedExercises.isEmpty {
                // 没有安排动作
                VStack(spacing: 12) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text(localization.text(english: "No exercises planned", chinese: "今日无训练安排"))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()

            } else {
                // 显示训练列表
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(plannedExercises) { planExercise in
                            if let exercise = planExercise.exercise {
                                ExerciseQuickCard(
                                    exercise: exercise,
                                    planExercise: planExercise
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct ExerciseQuickCard: View {
    let exercise: Exercise
    let planExercise: PlanExercise
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 动作名称
            Text(exercise.displayName(language: localization.language))
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .frame(height: 36)

            // 肌肉群标签
            MuscleGroupBadge(muscleGroup: exercise.muscleGroup)

            Divider()

            // 目标
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "number")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 16)
                    Text("\(planExercise.targetSets) " + localization.text(english: "sets", chinese: "组"))
                        .font(.caption)
                }

                HStack {
                    Image(systemName: "repeat")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 16)
                    Text("\(planExercise.targetReps) " + localization.text(english: "reps", chinese: "次"))
                        .font(.caption)
                }

                HStack {
                    Image(systemName: "timer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 16)
                    Text("\(planExercise.restSeconds)s " + localization.text(english: "rest", chinese: "休息"))
                        .font(.caption)
                }
            }
        }
        .padding(12)
        .frame(width: 160)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
