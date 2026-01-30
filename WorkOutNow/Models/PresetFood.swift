//
//  PresetFood.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/30.
//

import Foundation

/// 预设食物数据（不存储到SwiftData，仅用于快速选择）
struct PresetFood: Identifiable, Codable {
    let id: UUID
    let name: String
    let chineseName: String
    let category: FoodCategory
    let calories: Double // 每100g或每份的热量
    let servingSize: String // "100g" 或 "1碗"
    let proteinGrams: Double
    let carbsGrams: Double
    let fatGrams: Double

    init(
        id: UUID = UUID(),
        name: String,
        chineseName: String,
        category: FoodCategory,
        calories: Double,
        servingSize: String = "100g",
        proteinGrams: Double,
        carbsGrams: Double,
        fatGrams: Double
    ) {
        self.id = id
        self.name = name
        self.chineseName = chineseName
        self.category = category
        self.calories = calories
        self.servingSize = servingSize
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
    }
}

enum FoodCategory: String, Codable, CaseIterable {
    case grains = "Grains"
    case protein = "Protein"
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case dairy = "Dairy"
    case snacks = "Snacks"
    case beverages = "Beverages"

    var chineseName: String {
        switch self {
        case .grains: return "主食"
        case .protein: return "蛋白质"
        case .vegetables: return "蔬菜"
        case .fruits: return "水果"
        case .dairy: return "乳制品"
        case .snacks: return "零食"
        case .beverages: return "饮料"
        }
    }

    var icon: String {
        switch self {
        case .grains: return "🍚"
        case .protein: return "🍗"
        case .vegetables: return "🥬"
        case .fruits: return "🍎"
        case .dairy: return "🥛"
        case .snacks: return "🍪"
        case .beverages: return "🥤"
        }
    }
}

/// 预设食物数据库
struct PresetFoodDatabase {
    static let foods: [PresetFood] = [
        // 主食类
        PresetFood(name: "White Rice", chineseName: "白米饭", category: .grains, calories: 130, servingSize: "100g", proteinGrams: 2.7, carbsGrams: 28, fatGrams: 0.3),
        PresetFood(name: "Brown Rice", chineseName: "糙米饭", category: .grains, calories: 111, servingSize: "100g", proteinGrams: 2.6, carbsGrams: 23, fatGrams: 0.9),
        PresetFood(name: "Noodles", chineseName: "面条", category: .grains, calories: 137, servingSize: "100g", proteinGrams: 4.5, carbsGrams: 25, fatGrams: 0.5),
        PresetFood(name: "Bread", chineseName: "面包", category: .grains, calories: 265, servingSize: "100g", proteinGrams: 9, carbsGrams: 49, fatGrams: 3.2),
        PresetFood(name: "Sweet Potato", chineseName: "红薯", category: .grains, calories: 86, servingSize: "100g", proteinGrams: 1.6, carbsGrams: 20, fatGrams: 0.1),
        PresetFood(name: "Oatmeal", chineseName: "燕麦", category: .grains, calories: 68, servingSize: "100g", proteinGrams: 2.4, carbsGrams: 12, fatGrams: 1.4),

        // 蛋白质类
        PresetFood(name: "Chicken Breast", chineseName: "鸡胸肉", category: .protein, calories: 165, servingSize: "100g", proteinGrams: 31, carbsGrams: 0, fatGrams: 3.6),
        PresetFood(name: "Egg", chineseName: "鸡蛋", category: .protein, calories: 155, servingSize: "1个(50g)", proteinGrams: 13, carbsGrams: 1.1, fatGrams: 11),
        PresetFood(name: "Tofu", chineseName: "豆腐", category: .protein, calories: 76, servingSize: "100g", proteinGrams: 8, carbsGrams: 1.9, fatGrams: 4.8),
        PresetFood(name: "Salmon", chineseName: "三文鱼", category: .protein, calories: 208, servingSize: "100g", proteinGrams: 20, carbsGrams: 0, fatGrams: 13),
        PresetFood(name: "Beef", chineseName: "牛肉", category: .protein, calories: 250, servingSize: "100g", proteinGrams: 26, carbsGrams: 0, fatGrams: 15),
        PresetFood(name: "Pork", chineseName: "猪肉", category: .protein, calories: 242, servingSize: "100g", proteinGrams: 27, carbsGrams: 0, fatGrams: 14),

        // 蔬菜类
        PresetFood(name: "Broccoli", chineseName: "西兰花", category: .vegetables, calories: 34, servingSize: "100g", proteinGrams: 2.8, carbsGrams: 7, fatGrams: 0.4),
        PresetFood(name: "Spinach", chineseName: "菠菜", category: .vegetables, calories: 23, servingSize: "100g", proteinGrams: 2.9, carbsGrams: 3.6, fatGrams: 0.4),
        PresetFood(name: "Tomato", chineseName: "番茄", category: .vegetables, calories: 18, servingSize: "100g", proteinGrams: 0.9, carbsGrams: 3.9, fatGrams: 0.2),
        PresetFood(name: "Cucumber", chineseName: "黄瓜", category: .vegetables, calories: 15, servingSize: "100g", proteinGrams: 0.7, carbsGrams: 3.6, fatGrams: 0.1),
        PresetFood(name: "Carrot", chineseName: "胡萝卜", category: .vegetables, calories: 41, servingSize: "100g", proteinGrams: 0.9, carbsGrams: 10, fatGrams: 0.2),

        // 水果类
        PresetFood(name: "Apple", chineseName: "苹果", category: .fruits, calories: 52, servingSize: "100g", proteinGrams: 0.3, carbsGrams: 14, fatGrams: 0.2),
        PresetFood(name: "Banana", chineseName: "香蕉", category: .fruits, calories: 89, servingSize: "100g", proteinGrams: 1.1, carbsGrams: 23, fatGrams: 0.3),
        PresetFood(name: "Orange", chineseName: "橙子", category: .fruits, calories: 47, servingSize: "100g", proteinGrams: 0.9, carbsGrams: 12, fatGrams: 0.1),
        PresetFood(name: "Strawberry", chineseName: "草莓", category: .fruits, calories: 32, servingSize: "100g", proteinGrams: 0.7, carbsGrams: 8, fatGrams: 0.3),

        // 乳制品
        PresetFood(name: "Milk", chineseName: "牛奶", category: .dairy, calories: 61, servingSize: "100ml", proteinGrams: 3.2, carbsGrams: 4.8, fatGrams: 3.3),
        PresetFood(name: "Yogurt", chineseName: "酸奶", category: .dairy, calories: 59, servingSize: "100g", proteinGrams: 3.5, carbsGrams: 4.7, fatGrams: 3.3),
        PresetFood(name: "Cheese", chineseName: "奶酪", category: .dairy, calories: 402, servingSize: "100g", proteinGrams: 25, carbsGrams: 1.3, fatGrams: 33),

        // 零食类
        PresetFood(name: "Potato Chips", chineseName: "薯片", category: .snacks, calories: 536, servingSize: "100g", proteinGrams: 7, carbsGrams: 53, fatGrams: 35),
        PresetFood(name: "Chocolate", chineseName: "巧克力", category: .snacks, calories: 546, servingSize: "100g", proteinGrams: 5, carbsGrams: 59, fatGrams: 31),
        PresetFood(name: "Cookie", chineseName: "饼干", category: .snacks, calories: 502, servingSize: "100g", proteinGrams: 6, carbsGrams: 65, fatGrams: 24),

        // 饮料类
        PresetFood(name: "Coca Cola", chineseName: "可乐", category: .beverages, calories: 42, servingSize: "100ml", proteinGrams: 0, carbsGrams: 10.6, fatGrams: 0),
        PresetFood(name: "Orange Juice", chineseName: "橙汁", category: .beverages, calories: 45, servingSize: "100ml", proteinGrams: 0.7, carbsGrams: 10.4, fatGrams: 0.2),
        PresetFood(name: "Coffee", chineseName: "咖啡(无糖)", category: .beverages, calories: 2, servingSize: "100ml", proteinGrams: 0.3, carbsGrams: 0, fatGrams: 0),
    ]

    /// 按分类获取食物
    static func foods(for category: FoodCategory) -> [PresetFood] {
        foods.filter { $0.category == category }
    }

    /// 搜索食物
    static func search(query: String) -> [PresetFood] {
        let lowercased = query.lowercased()
        return foods.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.chineseName.contains(query)
        }
    }
}
