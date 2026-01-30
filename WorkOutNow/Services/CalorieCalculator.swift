//
//  CalorieCalculator.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/30.
//

import Foundation

/// 热量计算器 - 计算基础代谢率和运动消耗
struct CalorieCalculator {

    // MARK: - 基础代谢率计算

    /// 使用Mifflin-St Jeor公式计算基础代谢率（BMR）
    /// - Parameters:
    ///   - weightKg: 体重（千克）
    ///   - heightCm: 身高（厘米）
    ///   - age: 年龄
    ///   - gender: 性别
    /// - Returns: 每日基础代谢热量（千卡）
    static func calculateBMR(
        weightKg: Double,
        heightCm: Double,
        age: Int,
        gender: Gender
    ) -> Double {
        // Mifflin-St Jeor公式
        // 男性: BMR = 10 × 体重(kg) + 6.25 × 身高(cm) - 5 × 年龄 + 5
        // 女性: BMR = 10 × 体重(kg) + 6.25 × 身高(cm) - 5 × 年龄 - 161

        let base = 10 * weightKg + 6.25 * heightCm - 5 * Double(age)

        switch gender {
        case .male:
            return base + 5
        case .female:
            return base - 161
        case .other, .preferNotToSay:
            // 使用平均值
            return base - 78
        }
    }

    /// 根据活动水平计算每日总消耗（TDEE）
    /// - Parameters:
    ///   - bmr: 基础代谢率
    ///   - activityLevel: 活动水平
    /// - Returns: 每日总消耗（千卡）
    static func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        return bmr * activityLevel.multiplier
    }

    // MARK: - 运动消耗计算

    /// 计算力量训练消耗的热量
    /// - Parameters:
    ///   - workoutLog: 训练日志
    ///   - userProfile: 用户信息
    /// - Returns: 消耗的热量（千卡），如果数据不足返回nil
    static func calculateStrengthTrainingCalories(
        workoutLog: WorkoutLog,
        userProfile: UserProfile
    ) -> Double? {
        guard let weightKg = userProfile.weightKg,
              let sets = workoutLog.sets,
              !sets.isEmpty else {
            return nil
        }

        // 获取训练强度
        let intensity = determineWorkoutIntensity(workoutLog: workoutLog)

        // 根据强度获取MET值
        let met = getMETForStrengthTraining(intensity: intensity)

        // 计算训练时长（小时）
        let durationHours: Double
        if let duration = workoutLog.duration {
            durationHours = Double(duration) / 3600.0
        } else {
            // 如果没有记录时长，根据组数估算
            // 假设每组平均45秒动作 + 休息时间
            let totalSets = sets.count
            let avgRestSeconds = sets.compactMap { $0.restSeconds }.reduce(0, +) / max(sets.count, 1)
            let estimatedSeconds = Double(totalSets) * (45.0 + Double(avgRestSeconds))
            durationHours = estimatedSeconds / 3600.0
        }

        // 热量消耗 = MET × 体重(kg) × 时间(小时)
        return met * weightKg * durationHours
    }

    /// 计算有氧运动消耗的热量
    /// - Parameters:
    ///   - durationMinutes: 运动时长（分钟）
    ///   - intensity: 强度等级（1-10）
    ///   - weightKg: 体重（千克）
    /// - Returns: 消耗的热量（千卡）
    static func calculateCardioCalories(
        durationMinutes: Double,
        intensity: Int,
        weightKg: Double
    ) -> Double {
        let met = getMETForCardio(intensity: intensity)
        let durationHours = durationMinutes / 60.0
        return met * weightKg * durationHours
    }

    // MARK: - 辅助方法

    /// 根据训练数据判断训练强度
    private static func determineWorkoutIntensity(workoutLog: WorkoutLog) -> WorkoutIntensity {
        // 如果用户手动设置了强度评分
        if let rating = workoutLog.intensityRating {
            switch rating {
            case 1...3: return .light
            case 4...6: return .moderate
            case 7...8: return .vigorous
            case 9...10: return .veryVigorous
            default: return .moderate
            }
        }

        // 否则根据训练数据估算
        guard let sets = workoutLog.sets, !sets.isEmpty else {
            return .moderate
        }

        // 计算平均重量和次数
        let avgWeight = sets.compactMap { $0.weightKg }.reduce(0, +) / Double(max(sets.filter { $0.weightKg != nil }.count, 1))
        let avgReps = Double(sets.map { $0.reps }.reduce(0, +)) / Double(sets.count)

        // 重量越大、次数越少 = 高强度
        // 重量较小、次数较多 = 中低强度
        if avgWeight > 50 && avgReps < 8 {
            return .veryVigorous
        } else if avgWeight > 30 && avgReps < 12 {
            return .vigorous
        } else if avgReps > 15 {
            return .light
        } else {
            return .moderate
        }
    }

    /// 获取力量训练的MET值
    private static func getMETForStrengthTraining(intensity: WorkoutIntensity) -> Double {
        switch intensity {
        case .light: return 3.5
        case .moderate: return 5.0
        case .vigorous: return 6.0
        case .veryVigorous: return 8.0
        }
    }

    /// 获取有氧运动的MET值
    private static func getMETForCardio(intensity: Int) -> Double {
        // 基于强度等级（1-10）返回MET值
        switch intensity {
        case 1...2: return 3.0  // 慢走
        case 3...4: return 4.5  // 快走
        case 5...6: return 6.0  // 慢跑
        case 7...8: return 8.5  // 跑步
        case 9...10: return 11.0 // 快跑/高强度
        default: return 6.0
        }
    }

    /// 根据肌肉群获取MET调整系数
    private static func getMETMultiplierForMuscleGroup(_ muscleGroup: MuscleGroup) -> Double {
        switch muscleGroup {
        case .legs, .fullBody:
            return 1.2 // 大肌群消耗更多
        case .back, .chest:
            return 1.1
        case .shoulders, .core:
            return 1.0
        case .biceps, .triceps:
            return 0.9 // 小肌群消耗较少
        case .cardio:
            return 1.0
        }
    }

    // MARK: - 营养目标计算

    /// 计算每日热量目标
    /// - Parameters:
    ///   - tdee: 每日总消耗
    ///   - goal: 健身目标
    /// - Returns: 建议的每日热量摄入（千卡）
    static func calculateDailyCalorieTarget(tdee: Double, goal: FitnessGoal) -> Double {
        switch goal {
        case .lose:
            return tdee - 500 // 每日赤字500卡，约每周减重0.5kg
        case .maintain:
            return tdee
        case .gain:
            return tdee + 300 // 每日盈余300卡，约每周增重0.3kg
        }
    }

    /// 计算营养素目标（蛋白质、碳水、脂肪）
    /// - Parameters:
    ///   - dailyCalories: 每日热量目标
    ///   - weightKg: 体重
    ///   - goal: 健身目标
    /// - Returns: (蛋白质克数, 碳水克数, 脂肪克数)
    static func calculateMacroTargets(
        dailyCalories: Double,
        weightKg: Double,
        goal: FitnessGoal
    ) -> (protein: Double, carbs: Double, fat: Double) {
        let proteinGramsPerKg: Double
        let proteinPercentage: Double
        let fatPercentage: Double

        switch goal {
        case .lose:
            // 减脂：高蛋白，中碳水，低脂肪
            proteinGramsPerKg = 2.0
            proteinPercentage = 0.30
            fatPercentage = 0.25
        case .maintain:
            // 维持：均衡
            proteinGramsPerKg = 1.6
            proteinPercentage = 0.25
            fatPercentage = 0.30
        case .gain:
            // 增肌：高蛋白，高碳水，中脂肪
            proteinGramsPerKg = 1.8
            proteinPercentage = 0.25
            fatPercentage = 0.25
        }

        let proteinGrams = weightKg * proteinGramsPerKg
        let proteinCalories = proteinGrams * 4 // 1g蛋白质 = 4kcal
        let fatCalories = dailyCalories * fatPercentage
        let fatGrams = fatCalories / 9 // 1g脂肪 = 9kcal
        let carbsCalories = dailyCalories - proteinCalories - fatCalories
        let carbsGrams = carbsCalories / 4 // 1g碳水 = 4kcal

        return (protein: proteinGrams, carbs: carbsGrams, fat: fatGrams)
    }
}

// MARK: - Supporting Types

enum WorkoutIntensity {
    case light          // 轻度：低重量多次
    case moderate       // 中度：中等重量
    case vigorous       // 高度：大重量
    case veryVigorous   // 极高：极限重量
}

enum ActivityLevel {
    case sedentary      // 久坐（很少或不运动）
    case light          // 轻度活动（每周1-3天）
    case moderate       // 中度活动（每周3-5天）
    case active         // 积极活动（每周6-7天）
    case veryActive     // 非常活跃（每天2次训练）

    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }

    var chineseName: String {
        switch self {
        case .sedentary: return "久坐"
        case .light: return "轻度活动"
        case .moderate: return "中度活动"
        case .active: return "积极活动"
        case .veryActive: return "非常活跃"
        }
    }
}

enum FitnessGoal {
    case lose       // 减脂
    case maintain   // 维持
    case gain       // 增肌

    var chineseName: String {
        switch self {
        case .lose: return "减脂"
        case .maintain: return "维持"
        case .gain: return "增肌"
        }
    }
}
