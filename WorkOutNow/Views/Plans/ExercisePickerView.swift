//
//  ExercisePickerView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI
import SwiftData

struct ExercisePickerView: View {
    let dayTemplate: DayTemplate

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var localization
    @Query(sort: \Exercise.nameEnglish) private var exercises: [Exercise]

    @State private var searchText = ""
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var selectedExercise: Exercise?
    @State private var showingSettings = false

    var filteredExercises: [Exercise] {
        var result = exercises

        if let muscleGroup = selectedMuscleGroup {
            result = result.filter { $0.muscleGroup == muscleGroup }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.nameEnglish.localizedCaseInsensitiveContains(searchText) ||
                $0.nameChinese.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: localization.text(english: "All", chinese: "全部"),
                            isSelected: selectedMuscleGroup == nil,
                            action: { selectedMuscleGroup = nil }
                        )

                        ForEach(MuscleGroup.allCases, id: \.self) { group in
                            FilterChip(
                                title: localization.muscleGroupName(group),
                                isSelected: selectedMuscleGroup == group,
                                action: { selectedMuscleGroup = group }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                List(filteredExercises) { exercise in
                    Button(action: {
                        selectedExercise = exercise
                        showingSettings = true
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.displayName(language: localization.language))
                                .font(.headline)
                                .foregroundColor(.primary)
                            MuscleGroupBadge(muscleGroup: exercise.muscleGroup)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .searchable(text: $searchText, prompt: localization.text(english: "Search exercises", chinese: "搜索动作"))
            }
            .navigationTitle(localization.text(english: "Select Exercise", chinese: "选择动作"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.text(english: "Cancel", chinese: "取消")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                if let exercise = selectedExercise {
                    ExerciseSettingsView(
                        exercise: exercise,
                        dayTemplate: dayTemplate,
                        onSave: { sets, reps, rest in
                            addExercise(exercise: exercise, sets: sets, reps: reps, rest: rest)
                        }
                    )
                }
            }
        }
    }

    private func addExercise(exercise: Exercise, sets: Int, reps: Int, rest: Int) {
        let order = (dayTemplate.exercises?.count ?? 0)
        let planExercise = PlanExercise(
            order: order,
            targetSets: sets,
            targetReps: reps,
            restSeconds: rest
        )

        planExercise.exercise = exercise
        planExercise.dayTemplate = dayTemplate

        modelContext.insert(planExercise)
        dismiss()
    }
}

struct ExerciseSettingsView: View {
    let exercise: Exercise
    let dayTemplate: DayTemplate
    let onSave: (Int, Int, Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var localization
    @State private var targetSets: Int
    @State private var targetReps: Int
    @State private var restSeconds: Int

    init(exercise: Exercise, dayTemplate: DayTemplate, onSave: @escaping (Int, Int, Int) -> Void) {
        self.exercise = exercise
        self.dayTemplate = dayTemplate
        self.onSave = onSave

        _targetSets = State(initialValue: exercise.defaultSets ?? 3)
        _targetReps = State(initialValue: exercise.defaultReps ?? 10)
        _restSeconds = State(initialValue: exercise.defaultRestSeconds ?? 90)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(localization.text(english: "Exercise", chinese: "动作"))) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.displayName(language: localization.language))
                            .font(.headline)
                    }
                }

                Section(header: Text(localization.text(english: "Target Settings", chinese: "目标设置"))) {
                    Stepper(localization.text(english: "Sets: \(targetSets)", chinese: "组数: \(targetSets)"), value: $targetSets, in: 1...10)
                    Stepper(localization.text(english: "Reps: \(targetReps)", chinese: "次数: \(targetReps)"), value: $targetReps, in: 1...50)
                    Stepper(localization.text(english: "Rest: \(restSeconds)s", chinese: "休息: \(restSeconds)s"), value: $restSeconds, in: 30...300, step: 15)
                }
            }
            .navigationTitle(localization.text(english: "Settings", chinese: "设置参数"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.text(english: "Cancel", chinese: "取消")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.text(english: "Add", chinese: "添加")) {
                        onSave(targetSets, targetReps, restSeconds)
                        dismiss()
                    }
                }
            }
        }
    }
}
