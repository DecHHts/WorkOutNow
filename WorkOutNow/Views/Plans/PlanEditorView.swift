//
//  PlanEditorView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI
import SwiftData

struct PlanEditorView: View {
    @Bindable var plan: TrainingPlan
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization

    var sortedDayTemplates: [DayTemplate] {
        (plan.dayTemplates ?? []).sorted { $0.dayNumber < $1.dayNumber }
    }

    var body: some View {
        List {
            Section(header: Text(localization.text(english: "Plan Info", chinese: "计划信息"))) {
                HStack {
                    Text(localization.text(english: "Name", chinese: "名称"))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(plan.name)
                        .fontWeight(.semibold)
                }

                HStack {
                    Text(localization.text(english: "Cycle Days", chinese: "循环天数"))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(plan.cycleDays)")
                        .fontWeight(.semibold)
                }

                HStack {
                    Text(localization.text(english: "Start Date", chinese: "开始日期"))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(plan.startDate, format: .dateTime.year().month().day())
                        .fontWeight(.semibold)
                }

                Toggle(localization.text(english: "Active", chinese: "激活"), isOn: $plan.isActive)
            }

            Section(header: Text(localization.text(english: "Training Schedule", chinese: "训练日程"))) {
                ForEach(sortedDayTemplates) { dayTemplate in
                    NavigationLink(destination: DayTemplateEditorView(dayTemplate: dayTemplate)) {
                        DayTemplateRow(dayTemplate: dayTemplate)
                    }
                }
            }
        }
        .navigationTitle(plan.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct DayTemplateRow: View {
    let dayTemplate: DayTemplate
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(localization.text(english: "Day \(dayTemplate.dayNumber)", chinese: "第\(dayTemplate.dayNumber)天"))
                    .font(.headline)

                if dayTemplate.isRestDay {
                    Text(localization.text(english: "Rest", chinese: "休息"))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }

            if let name = dayTemplate.name, !name.isEmpty {
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if !dayTemplate.isRestDay {
                let exerciseCount = dayTemplate.exercises?.count ?? 0
                Text(localization.text(english: "\(exerciseCount) exercises", chinese: "\(exerciseCount)个动作"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
