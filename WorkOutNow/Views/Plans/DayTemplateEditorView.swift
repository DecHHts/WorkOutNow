//
//  DayTemplateEditorView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI
import SwiftData

struct DayTemplateEditorView: View {
    @Bindable var dayTemplate: DayTemplate
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization
    @State private var showingExercisePicker = false

    var sortedExercises: [PlanExercise] {
        (dayTemplate.exercises ?? []).sorted { $0.order < $1.order }
    }

    var body: some View {
        List {
            Section(header: Text(localization.text(english: "Day Settings", chinese: "日期设置"))) {
                TextField(localization.text(english: "Name (Optional)", chinese: "名称 (可选)"), text: Binding(
                    get: { dayTemplate.name ?? "" },
                    set: { dayTemplate.name = $0.isEmpty ? nil : $0 }
                ))

                Toggle(localization.text(english: "Rest Day", chinese: "休息日"), isOn: $dayTemplate.isRestDay)
            }

            if !dayTemplate.isRestDay {
                Section(header: Text(localization.text(english: "Exercises", chinese: "训练动作"))) {
                    if sortedExercises.isEmpty {
                        Text(localization.text(english: "Tap below to add exercises", chinese: "点击下方添加动作"))
                            .foregroundColor(.secondary)
                            .font(.caption)
                    } else {
                        ForEach(sortedExercises) { planExercise in
                            PlanExerciseRow(planExercise: planExercise)
                        }
                        .onDelete(perform: deleteExercises)
                        .onMove(perform: moveExercises)
                    }
                }

                Button(action: { showingExercisePicker = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(localization.text(english: "Add Exercise", chinese: "添加动作"))
                    }
                }
            }
        }
        .navigationTitle(localization.text(english: "Day \(dayTemplate.dayNumber)", chinese: "第\(dayTemplate.dayNumber)天"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !dayTemplate.isRestDay && !sortedExercises.isEmpty {
                EditButton()
            }
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView(dayTemplate: dayTemplate)
        }
    }

    private func deleteExercises(at offsets: IndexSet) {
        for index in offsets {
            let planExercise = sortedExercises[index]
            modelContext.delete(planExercise)
        }
        reorderExercises()
    }

    private func moveExercises(from source: IndexSet, to destination: Int) {
        var exercises = sortedExercises
        exercises.move(fromOffsets: source, toOffset: destination)

        for (index, exercise) in exercises.enumerated() {
            exercise.order = index
        }
    }

    private func reorderExercises() {
        let exercises = sortedExercises
        for (index, exercise) in exercises.enumerated() {
            exercise.order = index
        }
    }
}

struct PlanExerciseRow: View {
    let planExercise: PlanExercise
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let exercise = planExercise.exercise {
                Text(exercise.displayName(language: localization.language))
                    .font(.headline)
            }

            HStack(spacing: 12) {
                Text(localization.text(english: "\(planExercise.targetSets) sets", chinese: "\(planExercise.targetSets)组"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("×")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(localization.text(english: "\(planExercise.targetReps) reps", chinese: "\(planExercise.targetReps)次"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(localization.text(english: "Rest \(planExercise.restSeconds)s", chinese: "休息\(planExercise.restSeconds)s"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
