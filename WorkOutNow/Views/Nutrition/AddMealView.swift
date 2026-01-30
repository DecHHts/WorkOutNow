//
//  AddMealView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/30.
//

import SwiftUI
import SwiftData

struct AddMealView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var localization

    let date: Date
    let mealType: MealType
    @Binding var dailyRecord: DailyMealRecord?

    @State private var mode: InputMode = .quick
    @State private var showingFoodDatabase = false

    // 快速模式
    @State private var quickFoodName = ""
    @State private var quickCalories: Double = 100

    // 详细模式
    @State private var detailedFoodName = ""
    @State private var detailedServingSize = ""
    @State private var detailedCalories: Double = 100
    @State private var detailedProtein: Double = 0
    @State private var detailedCarbs: Double = 0
    @State private var detailedFat: Double = 0

    var body: some View {
        NavigationStack {
            Form {
                // 模式切换
                Section {
                    Picker("输入模式", selection: $mode) {
                        Text("快速模式").tag(InputMode.quick)
                        Text("详细模式").tag(InputMode.detailed)
                    }
                    .pickerStyle(.segmented)
                }

                if mode == .quick {
                    quickModeSection
                } else {
                    detailedModeSection
                }

                // 从食物库选择
                Section {
                    Button {
                        showingFoodDatabase = true
                    } label: {
                        Label("从食物库选择", systemImage: "book.fill")
                    }
                }
            }
            .navigationTitle(mealType.icon + " " + mealType.chineseName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveMeal()
                    }
                    .disabled(!canSave)
                }
            }
        }
        .sheet(isPresented: $showingFoodDatabase) {
                FoodDatabaseView(
                    onSelectFood: { food in
                        applyPresetFood(food)
                        showingFoodDatabase = false
                    }
                )
            }
    }

    // MARK: - Quick Mode Section

    private var quickModeSection: some View {
        Section {
            TextField("食物名称（可选）", text: $quickFoodName)

            VStack(alignment: .leading, spacing: 8) {
                Text("热量: \(Int(quickCalories)) kcal")
                    .font(.headline)

                Slider(value: $quickCalories, in: 10...2000, step: 10)

                HStack {
                    Text("10")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("2000")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("快速输入")
        } footer: {
            Text("快速模式只需输入热量，适合快速记录")
        }
    }

    // MARK: - Detailed Mode Section

    private var detailedModeSection: some View {
        Group {
            Section("基本信息") {
                TextField("食物名称", text: $detailedFoodName)
                TextField("份量（如：100g, 1碗）", text: $detailedServingSize)
            }

            Section("营养信息") {
                HStack {
                    Text("热量")
                    Spacer()
                    TextField("0", value: $detailedCalories, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("kcal")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("蛋白质")
                    Spacer()
                    TextField("0", value: $detailedProtein, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("g")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("碳水化合物")
                    Spacer()
                    TextField("0", value: $detailedCarbs, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("g")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("脂肪")
                    Spacer()
                    TextField("0", value: $detailedFat, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("g")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Text("提示：1g蛋白质≈4kcal，1g碳水≈4kcal，1g脂肪≈9kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Helper Methods

    private var canSave: Bool {
        if mode == .quick {
            return quickCalories > 0
        } else {
            return !detailedFoodName.isEmpty && detailedCalories > 0
        }
    }

    private func saveMeal() {
        guard let record = dailyRecord else { return }

        // 创建或获取该餐次
        let meal: Meal
        if let existingMeal = record.meals?.first(where: { $0.mealType == mealType }) {
            meal = existingMeal
        } else {
            meal = Meal(mealType: mealType, timestamp: Date())
            meal.dailyRecord = record
            modelContext.insert(meal)
        }

        // 创建食物条目
        let foodItem: FoodItem
        if mode == .quick {
            foodItem = FoodItem(
                name: quickFoodName.isEmpty ? "食物" : quickFoodName,
                calories: quickCalories
            )
        } else {
            foodItem = FoodItem(
                name: detailedFoodName,
                calories: detailedCalories,
                servingSize: detailedServingSize.isEmpty ? nil : detailedServingSize,
                proteinGrams: detailedProtein > 0 ? detailedProtein : nil,
                carbsGrams: detailedCarbs > 0 ? detailedCarbs : nil,
                fatGrams: detailedFat > 0 ? detailedFat : nil
            )
        }

        foodItem.meal = meal
        modelContext.insert(foodItem)

        try? modelContext.save()
        dismiss()
    }

    private func applyPresetFood(_ food: PresetFood) {
        mode = .detailed
        detailedFoodName = food.chineseName
        detailedServingSize = food.servingSize
        detailedCalories = food.calories
        detailedProtein = food.proteinGrams
        detailedCarbs = food.carbsGrams
        detailedFat = food.fatGrams
    }

    enum InputMode {
        case quick
        case detailed
    }
}

// MARK: - Food Database View

struct FoodDatabaseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: FoodCategory?

    let onSelectFood: (PresetFood) -> Void

    private var filteredFoods: [PresetFood] {
        var foods = PresetFoodDatabase.foods

        if let category = selectedCategory {
            foods = foods.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            foods = PresetFoodDatabase.search(query: searchText)
        }

        return foods
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 分类选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryChip(
                            title: "全部",
                            icon: "square.grid.2x2",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }

                        ForEach(FoodCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.chineseName,
                                icon: category.icon,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding()
                }

                Divider()

                // 食物列表
                List(filteredFoods) { food in
                    Button {
                        onSelectFood(food)
                    } label: {
                        FoodItemCell(food: food)
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "搜索食物")
            }
            .navigationTitle("食物库")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(icon)
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
            .foregroundStyle(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct FoodItemCell: View {
    let food: PresetFood

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(food.category.icon)
                Text(food.chineseName)
                    .font(.headline)
                Spacer()
                Text("\(Int(food.calories)) kcal")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            }

            HStack(spacing: 16) {
                Label("\(Int(food.proteinGrams))g", systemImage: "p.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)

                Label("\(Int(food.carbsGrams))g", systemImage: "c.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)

                Label("\(Int(food.fatGrams))g", systemImage: "f.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.purple)

                Spacer()

                Text(food.servingSize)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AddMealView(
        date: Date(),
        mealType: .breakfast,
        dailyRecord: .constant(DailyMealRecord())
    )
    .modelContainer(for: DailyMealRecord.self, inMemory: true)
}
