//
//  TrainingPlansView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI
import SwiftData

struct TrainingPlansView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization
    @Query(sort: \TrainingPlan.name) private var plans: [TrainingPlan]
    @State private var showingCreatePlan = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(plans) { plan in
                    NavigationLink(destination: PlanEditorView(plan: plan)) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(plan.name)
                                    .font(.headline)
                                if plan.isActive {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }

                            Text(localization.language == .chinese ? "\(plan.cycleDays)天循环" : "\(plan.cycleDays)-day cycle")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(localization.language == .chinese ? "开始日期: \(plan.startDate, format: .dateTime.year().month().day())" : "Start: \(plan.startDate, format: .dateTime.year().month().day())")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deletePlans)
            }
            .navigationTitle(localization.text(english: "Training Plans", chinese: "训练计划"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreatePlan = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreatePlan) {
                CreatePlanView()
            }
            .overlay {
                if plans.isEmpty {
                    ContentUnavailableView(
                        localization.text(english: "No Training Plans", chinese: "暂无训练计划"),
                        systemImage: "list.bullet.clipboard",
                        description: Text(localization.text(english: "Tap + to create a new training plan", chinese: "点击 + 创建新的训练计划"))
                    )
                }
            }
        }
    }

    private func deletePlans(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(plans[index])
        }
    }
}

#Preview {
    TrainingPlansView()
        .modelContainer(for: TrainingPlan.self, inMemory: true)
}
