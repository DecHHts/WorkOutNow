//
//  BodyMetricsDashboardView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/30.
//

import SwiftUI
import SwiftData
import Charts

struct BodyMetricsDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization
    @Environment(ThemeManager.self) private var themeManager

    @Query(sort: \BodyMetric.date, order: .reverse)
    private var allMetrics: [BodyMetric]

    @Query(sort: \WorkoutLog.date, order: .reverse)
    private var workoutLogs: [WorkoutLog]

    @Query(filter: #Predicate<NutritionPlan> { $0.isActive })
    private var activePlans: [NutritionPlan]

    @Query private var userProfiles: [UserProfile]

    @State private var selectedPeriod: TimePeriod = .month
    @State private var showingAddMetric = false

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    private var activePlan: NutritionPlan? {
        activePlans.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 时间段选择器
                    Picker("时间段", selection: $selectedPeriod) {
                        Text("月").tag(TimePeriod.month)
                        Text("季").tag(TimePeriod.quarter)
                        Text("年").tag(TimePeriod.year)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // 关键指标卡片
                    keyMetricsCards

                    // 体重变化趋势图
                    weightTrendChart

                    // 体重变化与热量关系
                    if activePlan != nil {
                        weightCalorieCorrelationChart
                    }

                    // 体重变化与训练频率
                    weightWorkoutCorrelationView

                    // 详细数据列表
                    metricsDetailList
                }
                .padding(.vertical)
            }
            .navigationTitle(localization.text(english: "Body Metrics", chinese: "身体数据"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddMetric = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMetric) {
                AddBodyMetricView()
            }
        }
    }

    // MARK: - Key Metrics Cards

    private var keyMetricsCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MetricCard(
                    title: "当前体重",
                    value: currentWeight != nil ? String(format: "%.1f", currentWeight!) : "--",
                    unit: "kg",
                    icon: "scalemass.fill",
                    color: .blue
                )

                MetricCard(
                    title: "体重变化",
                    value: weightChange != nil ? String(format: "%+.1f", weightChange!) : "--",
                    unit: "kg",
                    icon: weightChange ?? 0 >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                    color: weightChangeColor
                )
            }

            HStack(spacing: 12) {
                MetricCard(
                    title: "热量赤字",
                    value: "\(Int(abs(totalCalorieDeficit)))",
                    unit: "kcal",
                    icon: totalCalorieDeficit < 0 ? "flame.fill" : "plus.circle.fill",
                    color: totalCalorieDeficit < 0 ? .orange : .green
                )

                MetricCard(
                    title: "训练次数",
                    value: "\(workoutCount)",
                    unit: "次",
                    icon: "figure.strengthtraining.traditional",
                    color: .purple
                )
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Weight Trend Chart

    private var weightTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📈 " + localization.text(english: "Weight Trend", chinese: "体重趋势"))
                .font(.headline)
                .padding(.horizontal)

            if weightChartData.isEmpty {
                Text("暂无体重数据，点击右上角 + 添加")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Chart(weightChartData) { item in
                    LineMark(
                        x: .value("日期", item.date, unit: .day),
                        y: .value("体重", item.weight)
                    )
                    .foregroundStyle(.blue.gradient)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("日期", item.date, unit: .day),
                        y: .value("体重", item.weight)
                    )
                    .foregroundStyle(.blue)
                }
                .chartYScale(domain: weightYAxisRange)
                .frame(height: 200)
                .padding()
            }
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Weight-Calorie Correlation Chart

    private var weightCalorieCorrelationChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚖️ " + localization.text(english: "Weight & Calories", chinese: "体重与热量"))
                .font(.headline)
                .padding(.horizontal)

            Text("体重变化与热量平衡的关系")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            if !weightChartData.isEmpty {
                Chart {
                    ForEach(weightCalorieData) { item in
                        LineMark(
                            x: .value("日期", item.date, unit: .day),
                            y: .value("体重", item.weight)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)

                        if let netCalories = item.netCalories {
                            BarMark(
                                x: .value("日期", item.date, unit: .day),
                                y: .value("热量", netCalories / 100) // 缩放以适配Y轴
                            )
                            .foregroundStyle(netCalories >= 0 ? Color.green.opacity(0.5) : Color.orange.opacity(0.5))
                        }
                    }
                }
                .frame(height: 200)
                .padding()

                HStack(spacing: 20) {
                    Label("体重", systemImage: "circle.fill")
                        .foregroundStyle(.blue)
                        .font(.caption)

                    Label("热量盈余", systemImage: "square.fill")
                        .foregroundStyle(.green.opacity(0.5))
                        .font(.caption)

                    Label("热量赤字", systemImage: "square.fill")
                        .foregroundStyle(.orange.opacity(0.5))
                        .font(.caption)
                }
                .padding(.horizontal)
            }
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Weight-Workout Correlation

    private var weightWorkoutCorrelationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💪 " + localization.text(english: "Weight & Training", chinese: "体重与训练"))
                .font(.headline)
                .padding(.horizontal)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("本周训练")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(workoutCount) 次")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.purple)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    Text("体重变化")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let change = weightChange {
                        Text(String(format: "%+.1f kg", change))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(change < 0 ? .orange : .green)
                    } else {
                        Text("-- kg")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    Text("预测趋势")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(predictedTrend)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(predictedTrendColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()

            if let analysis = correlationAnalysis {
                Text(analysis)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Metrics Detail List

    private var metricsDetailList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 " + localization.text(english: "Details", chinese: "详细记录"))
                .font(.headline)
                .padding(.horizontal)

            if recentMetrics.isEmpty {
                Text("暂无记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(recentMetrics) { metric in
                        BodyMetricRow(metric: metric)
                    }
                }
                .padding()
            }
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Computed Properties

    private var weightChartData: [WeightDataPoint] {
        let calendar = Calendar.current
        let daysBack = selectedPeriod.days
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: Date())!

        return allMetrics
            .filter { $0.date >= startDate }
            .sorted { $0.date < $1.date }
            .compactMap { metric in
                guard let weight = metric.weightKg else { return nil }
                return WeightDataPoint(date: metric.date, weight: weight)
            }
    }

    private var weightCalorieData: [WeightCalorieDataPoint] {
        guard let plan = activePlan else { return [] }

        let calendar = Calendar.current
        let daysBack = selectedPeriod.days
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: Date())!

        var data: [WeightCalorieDataPoint] = []

        for metric in allMetrics.filter({ $0.date >= startDate }).sorted(by: { $0.date < $1.date }) {
            guard let weight = metric.weightKg else { continue }

            // 获取该日的热量数据
            let dayStart = calendar.startOfDay(for: metric.date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

            // 摄入热量
            let intake = plan.dailyRecords?.first(where: {
                $0.date >= dayStart && $0.date < dayEnd
            })?.totalCalories ?? 0

            // 消耗热量
            let burned = workoutLogs.filter {
                $0.date >= dayStart && $0.date < dayEnd
            }.compactMap { $0.caloriesBurned }.reduce(0, +)

            let netCalories = intake - burned

            data.append(WeightCalorieDataPoint(
                date: metric.date,
                weight: weight,
                netCalories: netCalories > 0 ? netCalories : nil
            ))
        }

        return data
    }

    private var currentWeight: Double? {
        allMetrics.first?.weightKg
    }

    private var weightChange: Double? {
        guard let current = currentWeight else { return nil }

        let calendar = Calendar.current
        let daysBack = selectedPeriod == .month ? 30 : (selectedPeriod == .quarter ? 90 : 365)
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: Date())!

        let oldMetric = allMetrics
            .filter { $0.date <= startDate }
            .sorted { $0.date > $1.date }
            .first

        guard let oldWeight = oldMetric?.weightKg else { return nil }

        return current - oldWeight
    }

    private var weightChangeColor: Color {
        guard let change = weightChange else { return .gray }
        return change < 0 ? .orange : .green
    }

    private var totalCalorieDeficit: Double {
        guard let plan = activePlan else { return 0 }

        let calendar = Calendar.current
        let daysBack = selectedPeriod.days
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: Date())!

        var totalDeficit: Double = 0

        for dayOffset in 0..<daysBack {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

            let intake = plan.dailyRecords?.first(where: {
                $0.date >= dayStart && $0.date < dayEnd
            })?.totalCalories ?? 0

            let burned = workoutLogs.filter {
                $0.date >= dayStart && $0.date < dayEnd
            }.compactMap { $0.caloriesBurned }.reduce(0, +)

            totalDeficit += (intake - burned - plan.dailyCalorieTarget)
        }

        return totalDeficit
    }

    private var workoutCount: Int {
        let calendar = Calendar.current
        let daysBack = selectedPeriod.days
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: Date())!

        return workoutLogs.filter { $0.date >= startDate }.count
    }

    private var recentMetrics: [BodyMetric] {
        let calendar = Calendar.current
        let daysBack = selectedPeriod.days
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: Date())!

        return allMetrics.filter { $0.date >= startDate }
    }

    private var weightYAxisRange: ClosedRange<Double> {
        let weights = weightChartData.map { $0.weight }
        guard !weights.isEmpty else { return 50...100 }

        let minWeight = weights.min()! - 2
        let maxWeight = weights.max()! + 2

        return minWeight...maxWeight
    }

    // MARK: - Predictive Analysis

    private var predictedTrend: String {
        guard let change = weightChange, workoutCount > 0 else { return "--" }

        let avgWeeklyWorkouts = Double(workoutCount) / Double(selectedPeriod.days / 7)

        if avgWeeklyWorkouts >= 4 && totalCalorieDeficit < 0 {
            return "↓"
        } else if avgWeeklyWorkouts >= 3 && totalCalorieDeficit < -1000 {
            return "↓"
        } else if totalCalorieDeficit > 2000 {
            return "↑"
        } else {
            return "→"
        }
    }

    private var predictedTrendColor: Color {
        switch predictedTrend {
        case "↓": return .orange
        case "↑": return .green
        default: return .blue
        }
    }

    private var correlationAnalysis: String? {
        guard let change = weightChange else { return nil }

        let avgWeeklyWorkouts = Double(workoutCount) / Double(selectedPeriod.days / 7)
        let avgCalorieDeficit = totalCalorieDeficit / Double(selectedPeriod.days)

        if avgWeeklyWorkouts >= 4 && avgCalorieDeficit < -300 {
            return "✨ 训练频率和热量控制都很理想，保持当前节奏！"
        } else if avgWeeklyWorkouts >= 3 && change < 0 {
            return "💪 训练坚持得不错，体重呈下降趋势"
        } else if avgWeeklyWorkouts < 2 && abs(change) < 0.5 {
            return "📝 建议增加训练频率，以达到更好的效果"
        } else if avgCalorieDeficit > 500 {
            return "⚠️ 热量摄入偏高，注意控制饮食"
        } else {
            return "继续保持，定期记录数据以追踪进展"
        }
    }

    enum TimePeriod {
        case month
        case quarter
        case year

        var days: Int {
            switch self {
            case .month: return 30
            case .quarter: return 90
            case .year: return 365
            }
        }
    }
}

// MARK: - Supporting Views

struct BodyMetricRow: View {
    let metric: BodyMetric

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(metric.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                Text(metric.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let weight = metric.weightKg {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("体重")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f kg", weight))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            if let bodyFat = metric.bodyFatPercentage {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("体脂率")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f%%", bodyFat))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .frame(width: 80)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Data Models

struct WeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

struct WeightCalorieDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let netCalories: Double?
}

#Preview {
    BodyMetricsDashboardView()
        .modelContainer(for: BodyMetric.self, inMemory: true)
}
