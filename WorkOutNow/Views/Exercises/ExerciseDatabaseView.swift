//
//  ExerciseDatabaseView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI
import SwiftData

struct ExerciseDatabaseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization
    @Query(sort: \Exercise.nameEnglish) private var exercises: [Exercise]
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var showingAddExercise = false

    var filteredExercises: [Exercise] {
        if let muscleGroup = selectedMuscleGroup {
            return exercises.filter { $0.muscleGroup == muscleGroup }
        }
        return exercises
    }

    var preBuiltExercises: [Exercise] {
        filteredExercises.filter { !$0.isCustom }
    }

    var customExercises: [Exercise] {
        filteredExercises.filter { $0.isCustom }
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

                List {
                    if !preBuiltExercises.isEmpty {
                        Section(header: Text(localization.text(english: "Pre-built Exercises", chinese: "预设动作"))) {
                            ForEach(preBuiltExercises) { exercise in
                                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                    ExerciseRow(exercise: exercise)
                                }
                            }
                        }
                    }

                    if !customExercises.isEmpty {
                        Section(header: Text(localization.text(english: "Custom Exercises", chinese: "自定义动作"))) {
                            ForEach(customExercises) { exercise in
                                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                    ExerciseRow(exercise: exercise)
                                }
                            }
                            .onDelete(perform: deleteCustomExercises)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle(localization.text(english: "Exercises", chinese: "动作库"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExercise = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddCustomExerciseView()
            }
        }
    }

    private func deleteCustomExercises(at offsets: IndexSet) {
        for index in offsets {
            let exercise = customExercises[index]
            modelContext.delete(exercise)
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.displayName(language: localization.language))
                .font(.headline)
            MuscleGroupBadge(muscleGroup: exercise.muscleGroup)
        }
        .padding(.vertical, 4)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

#Preview {
    ExerciseDatabaseView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
