//
//  CreatePlanView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI
import SwiftData

struct CreatePlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var localization

    @State private var planName = ""
    @State private var cycleDays = 7
    @State private var startDate = Date()
    @State private var isActive = true

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(localization.text(english: "Plan Info", chinese: "计划信息"))) {
                    TextField(localization.text(english: "Plan Name", chinese: "计划名称"), text: $planName)

                    Stepper(localization.text(english: "Cycle Days: \(cycleDays)", chinese: "循环天数: \(cycleDays)"), value: $cycleDays, in: 1...30)

                    DatePicker(
                        localization.text(english: "Start Date", chinese: "开始日期"),
                        selection: $startDate,
                        displayedComponents: .date
                    )

                    Toggle(localization.text(english: "Active Plan", chinese: "激活此计划"), isOn: $isActive)
                }

                Section {
                    Text(localization.text(english: "After creation, you can configure exercises for each day", chinese: "创建后，您可以为每一天配置训练动作"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(localization.text(english: "New Plan", chinese: "创建训练计划"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.text(english: "Cancel", chinese: "取消")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.text(english: "Create", chinese: "创建")) {
                        createPlan()
                    }
                    .disabled(planName.isEmpty)
                }
            }
        }
    }

    private func createPlan() {
        let plan = TrainingPlan(
            name: planName,
            cycleDays: cycleDays,
            startDate: Calendar.current.startOfDay(for: startDate),
            isActive: isActive
        )

        // Create day templates for each day in the cycle
        for day in 1...cycleDays {
            let dayTemplate = DayTemplate(dayNumber: day)
            dayTemplate.plan = plan
            modelContext.insert(dayTemplate)
        }

        modelContext.insert(plan)
        dismiss()
    }
}

#Preview {
    CreatePlanView()
        .modelContainer(for: TrainingPlan.self, inMemory: true)
}
