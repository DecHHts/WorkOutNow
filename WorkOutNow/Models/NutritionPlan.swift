//
//  NutritionPlan.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/30.
//

import Foundation
import SwiftData

@Model
final class NutritionPlan {
    var id: UUID
    var name: String
    var dailyCalorieTarget: Double // 每日热量目标（千卡）
    var proteinTargetGrams: Double? // 蛋白质目标（克）
    var carbsTargetGrams: Double? // 碳水化合物目标（克）
    var fatTargetGrams: Double? // 脂肪目标（克）
    var startDate: Date
    var isActive: Bool
    var createdAt: Date

    // 关联的训练计划（可选，允许独立存在）
    @Relationship(deleteRule: .nullify)
    var linkedTrainingPlan: TrainingPlan?

    // 每日餐食记录
    @Relationship(deleteRule: .cascade, inverse: \DailyMealRecord.nutritionPlan)
    var dailyRecords: [DailyMealRecord]?

    init(
        id: UUID = UUID(),
        name: String,
        dailyCalorieTarget: Double,
        proteinTargetGrams: Double? = nil,
        carbsTargetGrams: Double? = nil,
        fatTargetGrams: Double? = nil,
        startDate: Date = Date(),
        isActive: Bool = false,
        linkedTrainingPlan: TrainingPlan? = nil
    ) {
        self.id = id
        self.name = name
        self.dailyCalorieTarget = dailyCalorieTarget
        self.proteinTargetGrams = proteinTargetGrams
        self.carbsTargetGrams = carbsTargetGrams
        self.fatTargetGrams = fatTargetGrams
        self.startDate = startDate
        self.isActive = isActive
        self.linkedTrainingPlan = linkedTrainingPlan
        self.createdAt = Date()
    }

    /// 计算某日的完成度（0-1）
    func completionRate(for date: Date) -> Double {
        guard let record = dailyRecords?.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return 0
        }
        return min(record.totalCalories / dailyCalorieTarget, 1.0)
    }

    /// 获取某日的偏差百分比
    func deviationPercentage(for date: Date) -> Double {
        guard let record = dailyRecords?.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return 100 // 未记录视为100%偏差
        }
        return abs(record.totalCalories - dailyCalorieTarget) / dailyCalorieTarget * 100
    }
}

@Model
final class DailyMealRecord {
    var id: UUID
    var date: Date
    var notes: String?

    @Relationship(deleteRule: .nullify)
    var nutritionPlan: NutritionPlan?

    @Relationship(deleteRule: .cascade, inverse: \Meal.dailyRecord)
    var meals: [Meal]?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.notes = notes
    }

    /// 计算当日总热量
    var totalCalories: Double {
        meals?.reduce(0) { $0 + $1.totalCalories } ?? 0
    }

    /// 计算当日总蛋白质
    var totalProtein: Double {
        meals?.reduce(0) { $0 + $1.totalProtein } ?? 0
    }

    /// 计算当日总碳水
    var totalCarbs: Double {
        meals?.reduce(0) { $0 + $1.totalCarbs } ?? 0
    }

    /// 计算当日总脂肪
    var totalFat: Double {
        meals?.reduce(0) { $0 + $1.totalFat } ?? 0
    }
}

@Model
final class Meal {
    var id: UUID
    var mealType: MealType
    var timestamp: Date // 用餐时间

    @Relationship(deleteRule: .nullify)
    var dailyRecord: DailyMealRecord?

    @Relationship(deleteRule: .cascade, inverse: \FoodItem.meal)
    var foodItems: [FoodItem]?

    init(
        id: UUID = UUID(),
        mealType: MealType,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.mealType = mealType
        self.timestamp = timestamp
    }

    /// 计算该餐总热量
    var totalCalories: Double {
        foodItems?.reduce(0) { $0 + $1.calories } ?? 0
    }

    /// 计算该餐总蛋白质
    var totalProtein: Double {
        foodItems?.reduce(0) { $0 + ($1.proteinGrams ?? 0) } ?? 0
    }

    /// 计算该餐总碳水
    var totalCarbs: Double {
        foodItems?.reduce(0) { $0 + ($1.carbsGrams ?? 0) } ?? 0
    }

    /// 计算该餐总脂肪
    var totalFat: Double {
        foodItems?.reduce(0) { $0 + ($1.fatGrams ?? 0) } ?? 0
    }
}

@Model
final class FoodItem {
    var id: UUID
    var name: String
    var calories: Double // 热量（千卡）
    var servingSize: String? // 份量描述，如"100g"、"1碗"
    var proteinGrams: Double? // 蛋白质（克）
    var carbsGrams: Double? // 碳水化合物（克）
    var fatGrams: Double? // 脂肪（克）

    @Relationship(deleteRule: .nullify)
    var meal: Meal?

    init(
        id: UUID = UUID(),
        name: String,
        calories: Double,
        servingSize: String? = nil,
        proteinGrams: Double? = nil,
        carbsGrams: Double? = nil,
        fatGrams: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.servingSize = servingSize
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var chineseName: String {
        switch self {
        case .breakfast: return "早餐"
        case .lunch: return "午餐"
        case .dinner: return "晚餐"
        case .snack: return "加餐"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "🍳"
        case .lunch: return "🍱"
        case .dinner: return "🍜"
        case .snack: return "🍎"
        }
    }
}
