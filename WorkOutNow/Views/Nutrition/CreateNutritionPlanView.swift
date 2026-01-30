//
//  CreateNutritionPlanView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/30.
//

import SwiftUI
import SwiftData

struct CreateNutritionPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var localization

    @Query private var userProfiles: [UserProfile]
    @Query private var trainingPlans: [TrainingPlan]

    @State private var planName = ""
    @State private var dailyCalorieTarget: Double = 2000
    @State private var fitnessGoal: FitnessGoal = .maintain
    @State private var activityLevel: ActivityLevel = .moderate
    @State private var linkedTrainingPlan: TrainingPlan?
    @State private var autoCalculate = true
    @State private var customProtein: Double = 120
    @State private var customCarbs: Double = 250
    @State private var customFat: Double = 60

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    private var calculatedTargets: (calories: Double, protein: Double, carbs: Double, fat: Double)? {
        guard let profile = userProfile,
              let weight = profile.weightKg,
              let height = profile.heightCm,
              let birthday = profile.birthday else {
            return nil
        }

        let age = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 25
        let bmr = CalorieCalculator.calculateBMR(
            weightKg: weight,
            heightCm: height,
            age: age,
            gender: profile.gender
        )
        let tdee = CalorieCalculator.calculateTDEE(bmr: bmr, activityLevel: activityLevel)
        let targetCalories = CalorieCalculator.calculateDailyCalorieTarget(tdee: tdee, goal: fitnessGoal)
        let macros = CalorieCalculator.calculateMacroTargets(
            dailyCalories: targetCalories,
            weightKg: weight,
            goal: fitnessGoal
        )

        return (targetCalories, macros.protein, macros.carbs, macros.fat)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("计划名称", text: $planName)

                    if !trainingPlans.isEmpty {
                        Picker("关联训练计划（可选）", selection: $linkedTrainingPlan) {
                            Text("无").tag(nil as TrainingPlan?)
                            ForEach(trainingPlans) { plan in
                                Text(plan.name).tag(plan as TrainingPlan?)
                            }
                        }
                    }
                }

                Section("健身目标") {
                    Picker("目标", selection: $fitnessGoal) {
                        ForEach([FitnessGoal.lose, .maintain, .gain], id: \.self) { goal in
                            Text(goal.chineseName).tag(goal)
                        }
                    }

                    Picker("活动水平", selection: $activityLevel) {
                        ForEach([ActivityLevel.sedentary, .light, .moderate, .active, .veryActive], id: \.self) { level in
                            Text(level.chineseName).tag(level)
                        }
                    }
                }

                Section {
                    Toggle("自动计算营养目标", isOn: $autoCalculate)

                    if autoCalculate {
                        if let targets = calculatedTargets {
                            VStack(alignment: .leading, spacing: 12) {
                                targetRow(label: "每日热量", value: targets.calories, unit: "kcal", color: .orange)
                                targetRow(label: "蛋白质", value: targets.protein, unit: "g", color: .blue)
                                targetRow(label: "碳水化合物", value: targets.carbs, unit: "g", color: .green)
                                targetRow(label: "脂肪", value: targets.fat, unit: "g", color: .purple)
                            }
                        } else {
                            Text("请先在设置中完善个人信息（体重、身高、生日）")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        VStack(spacing: 12) {
                            HStack {
                                Text("每日热量")
                                Spacer()
                                TextField("2000", value: $dailyCalorieTarget, format: .number)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                Text("kcal")
                                    .foregroundStyle(.secondary)
                            }

                            HStack {
                                Text("蛋白质")
                                Spacer()
                                TextField("120", value: $customProtein, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                Text("g")
                                    .foregroundStyle(.secondary)
                            }

                            HStack {
                                Text("碳水化合物")
                                Spacer()
                                TextField("250", value: $customCarbs, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                Text("g")
                                    .foregroundStyle(.secondary)
                            }

                            HStack {
                                Text("脂肪")
                                Spacer()
                                TextField("60", value: $customFat, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                Text("g")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("营养目标")
                } footer: {
                    if autoCalculate {
                        Text("基于您的个人信息、活动水平和健身目标自动计算")
                    }
                }
            }
            .navigationTitle("创建饮食计划")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        createPlan()
                    }
                    .disabled(!canCreate)
                }
            }
        }
    }

    private func targetRow(label: String, value: Double, unit: String, color: Color) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(Int(value))")
                .fontWeight(.semibold)
                .foregroundStyle(color)
            + Text(" \(unit)")
                .foregroundStyle(.secondary)
        }
    }

    private var canCreate: Bool {
        !planName.isEmpty && (autoCalculate ? calculatedTargets != nil : dailyCalorieTarget > 0)
    }

    private func createPlan() {
        let targets: (calories: Double, protein: Double, carbs: Double, fat: Double)
        if autoCalculate, let calculated = calculatedTargets {
            targets = calculated
        } else {
            targets = (dailyCalorieTarget, customProtein, customCarbs, customFat)
        }

        let plan = NutritionPlan(
            name: planName,
            dailyCalorieTarget: targets.calories,
            proteinTargetGrams: targets.protein,
            carbsTargetGrams: targets.carbs,
            fatTargetGrams: targets.fat,
            isActive: true,
            linkedTrainingPlan: linkedTrainingPlan
        )

        // 停用其他计划
        for existingPlan in try! modelContext.fetch(FetchDescriptor<NutritionPlan>()) {
            existingPlan.isActive = false
        }

        modelContext.insert(plan)
        try? modelContext.save()

        dismiss()
    }
}

#Preview {
    CreateNutritionPlanView()
        .modelContainer(for: NutritionPlan.self, inMemory: true)
}
