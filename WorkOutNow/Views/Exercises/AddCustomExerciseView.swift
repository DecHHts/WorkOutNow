//
//  AddCustomExerciseView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI
import SwiftData

struct AddCustomExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var localization

    @State private var nameEnglish = ""
    @State private var nameChinese = ""
    @State private var selectedMuscleGroup = MuscleGroup.chest
    @State private var defaultSets = 3
    @State private var defaultReps = 10
    @State private var defaultRestSeconds = 90

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(localization.text(english: "Basic Info", chinese: "基本信息"))) {
                    TextField(localization.text(english: "English Name", chinese: "英文名称"), text: $nameEnglish)
                    TextField(localization.text(english: "Chinese Name", chinese: "中文名称"), text: $nameChinese)

                    Picker(localization.text(english: "Muscle Group", chinese: "肌肉群"), selection: $selectedMuscleGroup) {
                        ForEach(MuscleGroup.allCases, id: \.self) { group in
                            Text(localization.muscleGroupName(group)).tag(group)
                        }
                    }
                }

                Section(header: Text(localization.text(english: "Default Settings (Optional)", chinese: "默认设置 (可选)"))) {
                    Stepper(localization.text(english: "Sets: \(defaultSets)", chinese: "组数: \(defaultSets)"), value: $defaultSets, in: 1...10)
                    Stepper(localization.text(english: "Reps: \(defaultReps)", chinese: "次数: \(defaultReps)"), value: $defaultReps, in: 1...50)
                    Stepper(localization.text(english: "Rest: \(defaultRestSeconds)s", chinese: "休息时间: \(defaultRestSeconds)s"), value: $defaultRestSeconds, in: 30...300, step: 15)
                }
            }
            .navigationTitle(localization.text(english: "Add Exercise", chinese: "添加自定义动作"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.text(english: "Cancel", chinese: "取消")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.text(english: "Save", chinese: "保存")) {
                        saveExercise()
                    }
                    .disabled(nameEnglish.isEmpty || nameChinese.isEmpty)
                }
            }
        }
    }

    private func saveExercise() {
        let exercise = Exercise(
            nameEnglish: nameEnglish,
            nameChinese: nameChinese,
            muscleGroup: selectedMuscleGroup,
            isCustom: true,
            defaultSets: defaultSets,
            defaultReps: defaultReps,
            defaultRestSeconds: defaultRestSeconds
        )

        modelContext.insert(exercise)
        dismiss()
    }
}

#Preview {
    AddCustomExerciseView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
