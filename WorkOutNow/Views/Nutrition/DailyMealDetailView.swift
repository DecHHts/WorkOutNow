//
//  DailyMealDetailView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/30.
//

import SwiftUI
import SwiftData

struct DailyMealDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization
    @Environment(ThemeManager.self) private var themeManager

    let date: Date
    let nutritionPlan: NutritionPlan

    @State private var dailyRecord: DailyMealRecord?
    @State private var showingAddMeal = false
    @State private var selectedMealType: MealType?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 热量总览卡片
                calorieOverviewCard

                // 营养素分布
                if let record = dailyRecord {
                    macroNutrientsCard(record: record)
                }

                // 各餐详情
                ForEach(MealType.allCases, id: \.self) { mealType in
                    mealSection(for: mealType)
                }
            }
            .padding()
        }
        .navigationTitle(date.formatted(date: .long, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadOrCreateDailyRecord()
        }
        .sheet(item: $selectedMealType) { mealType in
            AddMealView(
                date: date,
                mealType: mealType,
                dailyRecord: $dailyRecord
            )
        }
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Calorie Overview Card

    private var calorieOverviewCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localization.text(english: "Daily Target", chinese: "每日目标"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(nutritionPlan.dailyCalorieTarget))")
                        .font(.title2)
                        .fontWeight(.bold)
                    + Text(" kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(localization.text(english: "Consumed", chinese: "已摄入"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(dailyRecord?.totalCalories ?? 0))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(calorieColor)
                    + Text(" kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(calorieColor)
                        .frame(
                            width: min(progressPercentage * geometry.size.width, geometry.size.width),
                            height: 8
                        )
                }
            }
            .frame(height: 8)

            // 百分比文本
            Text("\(Int(progressPercentage * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(themeManager.theme.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Macro Nutrients Card

    private func macroNutrientsCard(record: DailyMealRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💪 " + localization.text(english: "Nutrients", chinese: "营养素分布"))
                .font(.headline)

            HStack(spacing: 20) {
                nutrientItem(
                    name: localization.text(english: "Protein", chinese: "蛋白质"),
                    value: record.totalProtein,
                    target: nutritionPlan.proteinTargetGrams,
                    unit: "g",
                    color: .blue
                )

                nutrientItem(
                    name: localization.text(english: "Carbs", chinese: "碳水"),
                    value: record.totalCarbs,
                    target: nutritionPlan.carbsTargetGrams,
                    unit: "g",
                    color: .green
                )

                nutrientItem(
                    name: localization.text(english: "Fat", chinese: "脂肪"),
                    value: record.totalFat,
                    target: nutritionPlan.fatTargetGrams,
                    unit: "g",
                    color: .purple
                )
            }
        }
        .padding()
        .background(themeManager.theme.cardBackground)
        .cornerRadius(12)
    }

    private func nutrientItem(
        name: String,
        value: Double,
        target: Double?,
        unit: String,
        color: Color
    ) -> some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(Int(value))")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(color)

            if let target = target {
                Text("/ \(Int(target))\(unit)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Meal Section

    private func mealSection(for mealType: MealType) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(mealType.icon + " " + mealType.chineseName)
                    .font(.headline)

                Spacer()

                Text("\(Int(mealCalories(for: mealType))) kcal")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    selectedMealType = mealType
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
            }

            if let meals = mealsForType(mealType), !meals.isEmpty {
                ForEach(meals) { meal in
                    MealItemRow(meal: meal)
                }
            } else {
                Text(localization.text(english: "No food added", chinese: "未添加食物"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .background(themeManager.theme.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Helper Methods

    private func loadOrCreateDailyRecord() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<DailyMealRecord>(
            predicate: #Predicate { record in
                record.date >= startOfDay && record.date < endOfDay
            }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            dailyRecord = existing
        } else {
            let newRecord = DailyMealRecord(date: startOfDay)
            newRecord.nutritionPlan = nutritionPlan
            modelContext.insert(newRecord)
            dailyRecord = newRecord
        }
    }

    private func mealsForType(_ mealType: MealType) -> [Meal]? {
        dailyRecord?.meals?.filter { $0.mealType == mealType }
    }

    private func mealCalories(for mealType: MealType) -> Double {
        mealsForType(mealType)?.reduce(0) { $0 + $1.totalCalories } ?? 0
    }

    private var progressPercentage: Double {
        guard let total = dailyRecord?.totalCalories else { return 0 }
        return total / nutritionPlan.dailyCalorieTarget
    }

    private var calorieColor: Color {
        let percentage = progressPercentage
        if percentage < 0.9 {
            return .yellow
        } else if percentage <= 1.1 {
            return .green
        } else {
            return .red
        }
    }
}

// MARK: - Meal Item Row

struct MealItemRow: View {
    let meal: Meal

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(meal.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(Int(meal.totalCalories)) kcal")
                    .font(.caption)
                    .fontWeight(.medium)
            }

            if let foods = meal.foodItems, !foods.isEmpty {
                ForEach(foods) { food in
                    HStack {
                        Text("• \(food.name)")
                            .font(.subheadline)

                        Spacer()

                        Text("\(Int(food.calories)) kcal")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Daily Meal Summary View (for Calendar)

struct DailyMealSummaryView: View {
    @Environment(\.modelContext) private var modelContext
    let date: Date
    let nutritionPlan: NutritionPlan

    @State private var dailyRecord: DailyMealRecord?

    var body: some View {
        NavigationLink {
            DailyMealDetailView(date: date, nutritionPlan: nutritionPlan)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Text(date.formatted(date: .long, time: .omitted))
                    .font(.headline)

                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("目标")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(Int(nutritionPlan.dailyCalorieTarget)) kcal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    VStack(alignment: .leading) {
                        Text("已摄入")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(Int(dailyRecord?.totalCalories ?? 0)) kcal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(statusColor)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .buttonStyle(.plain)
        .onAppear {
            loadDailyRecord()
        }
    }

    private func loadDailyRecord() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<DailyMealRecord>(
            predicate: #Predicate { record in
                record.date >= startOfDay && record.date < endOfDay
            }
        )

        dailyRecord = try? modelContext.fetch(descriptor).first
    }

    private var statusColor: Color {
        guard let total = dailyRecord?.totalCalories else { return .gray }
        let deviation = abs(total - nutritionPlan.dailyCalorieTarget) / nutritionPlan.dailyCalorieTarget

        if deviation <= 0.1 {
            return .green
        } else if deviation <= 0.2 {
            return .yellow
        } else {
            return .red
        }
    }
}

extension MealType: Identifiable {
    var id: String { rawValue }
}

#Preview {
    NavigationStack {
        DailyMealDetailView(
            date: Date(),
            nutritionPlan: NutritionPlan(name: "测试计划", dailyCalorieTarget: 2000)
        )
    }
    .modelContainer(for: DailyMealRecord.self, inMemory: true)
}
