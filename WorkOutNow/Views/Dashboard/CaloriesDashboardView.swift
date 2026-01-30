//
//  CaloriesDashboardView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/30.
//

import SwiftUI
import SwiftData
import Charts

struct CaloriesDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization
    @Environment(ThemeManager.self) private var themeManager

    @Query(sort: \WorkoutLog.date, order: .reverse)
    private var workoutLogs: [WorkoutLog]

    @Query(filter: #Predicate<NutritionPlan> { $0.isActive })
    private var activePlans: [NutritionPlan]

    @State private var selectedPeriod: TimePeriod = .week
    @State private var selectedDate = Date()

    private var activePlan: NutritionPlan? {
        activePlans.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 时间段选择器
                    Picker("时间段", selection: $selectedPeriod) {
                        Text("周").tag(TimePeriod.week)
                        Text("月").tag(TimePeriod.month)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // 关键指标卡片
                    keyMetricsCards

                    // 热量消耗趋势图
                    caloriesBurnedChart

                    // 摄入vs消耗对比图
                    if activePlan != nil {
                        intakeVsBurnChart
                    }

                    // 本周详细数据
                    weeklyDetailList
                }
                .padding(.vertical)
            }
            .navigationTitle(localization.text(english: "Calories", chinese: "热量"))
        }
    }

    // MARK: - Key Metrics Cards

    private var keyMetricsCards: some View {
        HStack(spacing: 12) {
            MetricCard(
                title: "本周总消耗",
                value: "\(Int(weeklyTotalBurned))",
                unit: "kcal",
                icon: "flame.fill",
                color: .orange
            )

            MetricCard(
                title: "平均每日",
                value: "\(Int(dailyAverageBurned))",
                unit: "kcal",
                icon: "chart.bar.fill",
                color: .blue
            )

            MetricCard(
                title: "最高单日",
                value: "\(Int(maxDailyBurned))",
                unit: "kcal",
                icon: "arrow.up.circle.fill",
                color: .green
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Calories Burned Chart

    private var caloriesBurnedChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔥 " + localization.text(english: "Calories Burned", chinese: "热量消耗趋势"))
                .font(.headline)
                .padding(.horizontal)

            Chart(chartData) { item in
                BarMark(
                    x: .value("日期", item.date, unit: .day),
                    y: .value("热量", item.calories)
                )
                .foregroundStyle(.orange.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .padding()
            .background(themeManager.theme.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    // MARK: - Intake vs Burn Chart

    private var intakeVsBurnChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚖️ " + localization.text(english: "Intake vs Burn", chinese: "摄入vs消耗"))
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(intakeVsBurnData) { item in
                    BarMark(
                        x: .value("日期", item.date, unit: .day),
                        y: .value("热量", item.intake)
                    )
                    .foregroundStyle(.green.gradient)
                    .position(by: .value("类型", "摄入"))

                    BarMark(
                        x: .value("日期", item.date, unit: .day),
                        y: .value("热量", item.burn)
                    )
                    .foregroundStyle(.orange.gradient)
                    .position(by: .value("类型", "消耗"))
                }
            }
            .frame(height: 200)
            .padding()
            .background(themeManager.theme.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    // MARK: - Weekly Detail List

    private var weeklyDetailList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 " + localization.text(english: "Details", chinese: "本周详情"))
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(Array(chartData.enumerated()), id: \.element.id) { index, item in
                    DailyCalorieRow(
                        weekday: weekdayName(for: item.date),
                        date: item.date,
                        burned: item.calories,
                        intake: intakeForDate(item.date)
                    )
                }
            }
            .padding()
            .background(themeManager.theme.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    // MARK: - Helper Methods

    private var chartData: [CalorieDataPoint] {
        let calendar = Calendar.current
        let range = selectedPeriod == .week ? 7 : 30
        let startDate = calendar.date(byAdding: .day, value: -range + 1, to: selectedDate)!

        var data: [CalorieDataPoint] = []

        for dayOffset in 0..<range {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
            let logs = workoutLogs.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let totalCalories = logs.compactMap { $0.caloriesBurned }.reduce(0, +)

            data.append(CalorieDataPoint(date: date, calories: totalCalories))
        }

        return data
    }

    private var intakeVsBurnData: [IntakeVsBurnDataPoint] {
        guard activePlan != nil else { return [] }

        let calendar = Calendar.current
        let range = selectedPeriod == .week ? 7 : 30
        let startDate = calendar.date(byAdding: .day, value: -range + 1, to: selectedDate)!

        var data: [IntakeVsBurnDataPoint] = []

        for dayOffset in 0..<range {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
            let burned = chartData.first { calendar.isDate($0.date, inSameDayAs: date) }?.calories ?? 0
            let intake = intakeForDate(date)

            data.append(IntakeVsBurnDataPoint(date: date, intake: intake, burn: burned))
        }

        return data
    }

    private func intakeForDate(_ date: Date) -> Double {
        guard let plan = activePlan else { return 0 }

        let calendar = Calendar.current
        if let record = plan.dailyRecords?.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            return record.totalCalories
        }
        return 0
    }

    private var weeklyTotalBurned: Double {
        chartData.reduce(0) { $0 + $1.calories }
    }

    private var dailyAverageBurned: Double {
        let nonZeroData = chartData.filter { $0.calories > 0 }
        guard !nonZeroData.isEmpty else { return 0 }
        return nonZeroData.reduce(0) { $0 + $1.calories } / Double(nonZeroData.count)
    }

    private var maxDailyBurned: Double {
        chartData.map { $0.calories }.max() ?? 0
    }

    private func weekdayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    enum TimePeriod {
        case week
        case month
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            + Text(" " + unit)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DailyCalorieRow: View {
    let weekday: String
    let date: Date
    let burned: Double
    let intake: Double

    private var netCalories: Double {
        intake - burned
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(weekday)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(date.formatted(.dateTime.month().day()))
                    .font(.subheadline)
            }
            .frame(width: 60, alignment: .leading)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Text("摄入▲")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(Int(intake))")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }

                HStack(spacing: 4) {
                    Text("消耗▼")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(Int(burned))")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
            }

            VStack(alignment: .trailing, spacing: 4) {
                Text("净值")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(netCalories >= 0 ? "+\(Int(netCalories))" : "\(Int(netCalories))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(netCalories >= 0 ? .blue : .purple)
            }
            .frame(width: 80, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Data Models

struct CalorieDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Double
}

struct IntakeVsBurnDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let intake: Double
    let burn: Double
}

#Preview {
    CaloriesDashboardView()
        .modelContainer(for: WorkoutLog.self, inMemory: true)
}
