//
//  LogWorkoutView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI
import SwiftData

struct LogWorkoutView: View {
    let date: Date

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var localization
    @Query(sort: \Exercise.nameEnglish) private var exercises: [Exercise]

    @State private var selectedExercises: [ExerciseWorkoutData] = []
    @State private var duration: Int = 60
    @State private var intensityRating: Int = 5
    @State private var notes: String = ""
    @State private var showingExercisePicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(localization.text(english: "Date", chinese: "日期"))) {
                    Text(date, style: .date)
                        .fontWeight(.semibold)
                }

                Section(header: Text(localization.text(english: "Exercises", chinese: "训练动作"))) {
                    if selectedExercises.isEmpty {
                        Button(action: { showingExercisePicker = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(localization.text(english: "Add Exercise", chinese: "添加动作"))
                            }
                        }
                    } else {
                        ForEach($selectedExercises) { $exerciseData in
                            ExerciseSetEditor(exerciseData: $exerciseData)
                        }
                        .onDelete(perform: deleteExercise)

                        Button(action: { showingExercisePicker = true }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text(localization.text(english: "Add More", chinese: "添加更多动作"))
                            }
                        }
                    }
                }

                Section(header: Text(localization.text(english: "Workout Info", chinese: "训练信息"))) {
                    Stepper(localization.text(english: "Duration: \(duration) min", chinese: "时长: \(duration)分钟"), value: $duration, in: 5...300, step: 5)
                    Stepper(localization.text(english: "Intensity: \(intensityRating)/10", chinese: "强度: \(intensityRating)/10"), value: $intensityRating, in: 1...10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(localization.text(english: "Notes", chinese: "备注"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $notes)
                            .frame(height: 80)
                    }
                }
            }
            .navigationTitle(localization.text(english: "Log Workout", chinese: "记录训练"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.text(english: "Cancel", chinese: "取消")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.text(english: "Save", chinese: "保存")) {
                        saveWorkout()
                    }
                    .disabled(selectedExercises.isEmpty)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                SimpleExercisePickerView(
                    exercises: exercises,
                    onSelect: { exercise in
                        addExercise(exercise)
                    }
                )
            }
        }
    }

    private func addExercise(_ exercise: Exercise) {
        let exerciseData = ExerciseWorkoutData(
            exercise: exercise,
            sets: [SetData(setNumber: 1)]
        )
        selectedExercises.append(exerciseData)
    }

    private func deleteExercise(at offsets: IndexSet) {
        selectedExercises.remove(atOffsets: offsets)
    }

    private func saveWorkout() {
        let workoutLog = WorkoutLog(
            date: date,
            duration: TimeInterval(duration * 60),
            notes: notes.isEmpty ? nil : notes,
            intensityRating: intensityRating
        )

        for exerciseData in selectedExercises {
            for setData in exerciseData.sets {
                let workoutSet = WorkoutSet(
                    setNumber: setData.setNumber,
                    reps: setData.reps,
                    weightKg: setData.weight > 0 ? setData.weight : nil,
                    restSeconds: nil,
                    completedAt: date
                )
                workoutSet.exercise = exerciseData.exercise
                workoutSet.workoutLog = workoutLog
                modelContext.insert(workoutSet)
            }
        }

        modelContext.insert(workoutLog)
        dismiss()
    }
}

struct ExerciseWorkoutData: Identifiable {
    let id = UUID()
    let exercise: Exercise
    var sets: [SetData]
}

struct SetData: Identifiable {
    let id = UUID()
    let setNumber: Int
    var reps: Int = 10
    var weight: Double = 0
}

struct ExerciseSetEditor: View {
    @Binding var exerciseData: ExerciseWorkoutData
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(exerciseData.exercise.displayName(language: localization.language))
                    .font(.headline)
            }

            ForEach($exerciseData.sets) { $set in
                HStack(spacing: 12) {
                    Text(localization.text(english: "Set \(set.setNumber)", chinese: "第\(set.setNumber)组"))
                        .font(.caption)
                        .frame(width: 60, alignment: .leading)

                    TextField(localization.text(english: "Reps", chinese: "次数"), value: $set.reps, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 80)

                    TextField(localization.text(english: "Weight (kg)", chinese: "重量 (kg)"), value: $set.weight, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                }
            }

            Button(action: addSet) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text(localization.text(english: "Add Set", chinese: "添加组"))
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }

    private func addSet() {
        let nextSetNumber = (exerciseData.sets.last?.setNumber ?? 0) + 1
        let newSet = SetData(setNumber: nextSetNumber)
        exerciseData.sets.append(newSet)
    }
}

struct SimpleExercisePickerView: View {
    let exercises: [Exercise]
    let onSelect: (Exercise) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var localization
    @State private var searchText = ""
    @State private var selectedMuscleGroup: MuscleGroup?

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
                        onSelect(exercise)
                        dismiss()
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
        }
    }
}

#Preview {
    LogWorkoutView(date: Date())
        .modelContainer(for: Exercise.self, inMemory: true)
}
