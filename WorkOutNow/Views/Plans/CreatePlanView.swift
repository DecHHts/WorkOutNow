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
    @State private var createNutritionPlan = false
    @State private var nutritionPlanName = ""
    @State private var dailyCalorieTarget: Double = 2000

    @Query private var userProfiles: [UserProfile]

    private var userProfile: UserProfile? {
        userProfiles.first
    }

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
                    Toggle(localization.text(english: "Create Nutrition Plan", chinese: "同步创建饮食计划"), isOn: $createNutritionPlan)

                    if createNutritionPlan {
                        TextField(
                            localization.text(english: "Nutrition Plan Name", chinese: "饮食计划名称"),
                            text: $nutritionPlanName
                        )
                        .onAppear {
                            if nutritionPlanName.isEmpty {
                                nutritionPlanName = planName + " - 饮食计划"
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(localization.text(english: "Daily Calorie Target", chinese: "每日热量目标"))
                                .font(.subheadline)

                            HStack {
                                Slider(value: $dailyCalorieTarget, in: 1200...3500, step: 50)
                                Text("\(Int(dailyCalorieTarget)) kcal")
                                    .font(.subheadline)
                                    .foregroundStyle(.orange)
                                    .frame(width: 100, alignment: .trailing)
                            }

                            if let profile = userProfile,
                               let weight = profile.weightKg,
                               let height = profile.heightCm,
                               let birthday = profile.birthday {
                                let age = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 25
                                let bmr = CalorieCalculator.calculateBMR(
                                    weightKg: weight,
                                    heightCm: height,
                                    age: age,
                                    gender: profile.gender
                                )
                                let tdee = CalorieCalculator.calculateTDEE(bmr: bmr, activityLevel: .moderate)

                                Text("建议: \(Int(tdee)) kcal (基于您的个人信息)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text(localization.text(english: "Nutrition Plan", chinese: "饮食计划"))
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

        // 如果选择创建饮食计划，则同步创建
        if createNutritionPlan {
            let macros = calculateMacroTargets()

            let nutritionPlan = NutritionPlan(
                name: nutritionPlanName.isEmpty ? planName + " - 饮食计划" : nutritionPlanName,
                dailyCalorieTarget: dailyCalorieTarget,
                proteinTargetGrams: macros.protein,
                carbsTargetGrams: macros.carbs,
                fatTargetGrams: macros.fat,
                startDate: Calendar.current.startOfDay(for: startDate),
                isActive: true,
                linkedTrainingPlan: plan
            )

            // 停用其他饮食计划
            let descriptor = FetchDescriptor<NutritionPlan>()
            if let existingPlans = try? modelContext.fetch(descriptor) {
                for existingPlan in existingPlans {
                    existingPlan.isActive = false
                }
            }

            modelContext.insert(nutritionPlan)
        }

        try? modelContext.save()
        dismiss()
    }

    private func calculateMacroTargets() -> (protein: Double, carbs: Double, fat: Double) {
        guard let profile = userProfile, let weight = profile.weightKg else {
            // 使用默认值
            return CalorieCalculator.calculateMacroTargets(
                dailyCalories: dailyCalorieTarget,
                weightKg: 70,
                goal: .maintain
            )
        }

        return CalorieCalculator.calculateMacroTargets(
            dailyCalories: dailyCalorieTarget,
            weightKg: weight,
            goal: .maintain
        )
    }
}

#Preview {
    CreatePlanView()
        .modelContainer(for: TrainingPlan.self, inMemory: true)
}
