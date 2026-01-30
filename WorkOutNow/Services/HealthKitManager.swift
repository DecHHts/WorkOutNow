//
//  HealthKitManager.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/30.
//

import Foundation
import HealthKit
import SwiftData

/// HealthKit管理器 - 处理与Apple健康应用的双向数据同步
@MainActor
@Observable
class HealthKitManager {
    private let healthStore = HKHealthStore()

    // 权限状态
    var isAuthorized = false
    var authorizationError: String?

    // MARK: - 初始化

    init() {
        checkHealthKitAvailability()
    }

    // MARK: - 权限管理

    /// 检查HealthKit是否可用
    private func checkHealthKitAvailability() {
        guard HKHealthStore.isHealthDataAvailable() else {
            authorizationError = "HealthKit在此设备上不可用"
            return
        }
    }

    /// 请求HealthKit权限
    func requestAuthorization() async throws {
        // 定义需要读取的数据类型
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,              // 体重
            HKObjectType.quantityType(forIdentifier: .height)!,                // 身高
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,    // 活动热量
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!, // 饮食热量
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,        // 蛋白质
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,  // 碳水化合物
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!,       // 脂肪
            HKObjectType.workoutType()                                         // 训练数据
        ]

        // 定义需要写入的数据类型
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!,
            HKObjectType.workoutType()
        ]

        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            isAuthorized = true
            authorizationError = nil
        } catch {
            authorizationError = "无法获取HealthKit权限: \(error.localizedDescription)"
            throw error
        }
    }

    // MARK: - 读取数据

    /// 读取最新的体重数据
    func fetchLatestBodyWeight() async throws -> Double? {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            return nil
        }

        let samples = try await fetchMostRecentSample(for: weightType)
        guard let sample = samples.first else { return nil }

        return sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
    }

    /// 读取最新的身高数据
    func fetchLatestHeight() async throws -> Double? {
        guard let heightType = HKQuantityType.quantityType(forIdentifier: .height) else {
            return nil
        }

        let samples = try await fetchMostRecentSample(for: heightType)
        guard let sample = samples.first else { return nil }

        return sample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
    }

    /// 读取指定日期范围的活动热量
    func fetchActiveCalories(from startDate: Date, to endDate: Date) async throws -> Double {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return 0
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let samples = try await fetchSamples(for: calorieType, predicate: predicate)

        let total = samples.reduce(0.0) { sum, sample in
            sum + sample.quantity.doubleValue(for: .kilocalorie())
        }

        return total
    }

    /// 读取指定日期的饮食热量
    func fetchDietaryCalories(for date: Date) async throws -> Double {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) else {
            return 0
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let samples = try await fetchSamples(for: calorieType, predicate: predicate)

        let total = samples.reduce(0.0) { sum, sample in
            sum + sample.quantity.doubleValue(for: .kilocalorie())
        }

        return total
    }

    // MARK: - 写入数据

    /// 保存训练消耗的热量到健康应用
    func saveWorkoutCalories(
        calories: Double,
        startDate: Date,
        endDate: Date,
        activityType: HKWorkoutActivityType = .traditionalStrengthTraining
    ) async throws {
        // 创建训练记录
        let workout = HKWorkout(
            activityType: activityType,
            start: startDate,
            end: endDate,
            duration: endDate.timeIntervalSince(startDate),
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
            totalDistance: nil,
            metadata: [HKMetadataKeyIndoorWorkout: true]
        )

        try await healthStore.save(workout)

        // 同时保存热量消耗数据
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }

        let calorieQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
        let calorieSample = HKQuantitySample(
            type: calorieType,
            quantity: calorieQuantity,
            start: startDate,
            end: endDate
        )

        try await healthStore.save(calorieSample)
    }

    /// 保存饮食数据到健康应用
    func saveMealToHealth(
        calories: Double,
        protein: Double?,
        carbs: Double?,
        fat: Double?,
        timestamp: Date
    ) async throws {
        var samples: [HKQuantitySample] = []

        // 热量
        if let calorieType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) {
            let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
            let sample = HKQuantitySample(type: calorieType, quantity: quantity, start: timestamp, end: timestamp)
            samples.append(sample)
        }

        // 蛋白质
        if let protein = protein,
           let proteinType = HKQuantityType.quantityType(forIdentifier: .dietaryProtein) {
            let quantity = HKQuantity(unit: .gram(), doubleValue: protein)
            let sample = HKQuantitySample(type: proteinType, quantity: quantity, start: timestamp, end: timestamp)
            samples.append(sample)
        }

        // 碳水化合物
        if let carbs = carbs,
           let carbsType = HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates) {
            let quantity = HKQuantity(unit: .gram(), doubleValue: carbs)
            let sample = HKQuantitySample(type: carbsType, quantity: quantity, start: timestamp, end: timestamp)
            samples.append(sample)
        }

        // 脂肪
        if let fat = fat,
           let fatType = HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal) {
            let quantity = HKQuantity(unit: .gram(), doubleValue: fat)
            let sample = HKQuantitySample(type: fatType, quantity: quantity, start: timestamp, end: timestamp)
            samples.append(sample)
        }

        // 批量保存
        try await healthStore.save(samples)
    }

    /// 同步训练日志到健康应用
    func syncWorkoutLogToHealth(workoutLog: WorkoutLog, calories: Double) async throws {
        let endDate = workoutLog.duration != nil
            ? workoutLog.date.addingTimeInterval(workoutLog.duration!)
            : workoutLog.date.addingTimeInterval(3600) // 默认1小时

        try await saveWorkoutCalories(
            calories: calories,
            startDate: workoutLog.date,
            endDate: endDate
        )
    }

    /// 同步每日饮食记录到健康应用
    func syncDailyMealRecordToHealth(record: DailyMealRecord) async throws {
        guard let meals = record.meals else { return }

        for meal in meals {
            try await saveMealToHealth(
                calories: meal.totalCalories,
                protein: meal.totalProtein,
                carbs: meal.totalCarbs,
                fat: meal.totalFat,
                timestamp: meal.timestamp
            )
        }
    }

    // MARK: - 私有辅助方法

    /// 获取最新的样本
    private func fetchMostRecentSample(for quantityType: HKQuantityType) async throws -> [HKQuantitySample] {
        return try await withCheckedThrowingContinuation { continuation in
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: samples as? [HKQuantitySample] ?? [])
            }
            healthStore.execute(query)
        }
    }

    /// 获取指定条件的样本
    private func fetchSamples(
        for quantityType: HKQuantityType,
        predicate: NSPredicate
    ) async throws -> [HKQuantitySample] {
        return try await withCheckedThrowingContinuation { continuation in
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: samples as? [HKQuantitySample] ?? [])
            }
            healthStore.execute(query)
        }
    }

    // MARK: - 便捷方法

    /// 从健康应用同步用户基础数据到UserProfile
    func syncHealthDataToProfile(profile: UserProfile) async throws {
        if let weight = try await fetchLatestBodyWeight() {
            profile.weightKg = weight
        }

        if let height = try await fetchLatestHeight() {
            profile.heightCm = height
        }

        profile.updatedAt = Date()
    }
}
