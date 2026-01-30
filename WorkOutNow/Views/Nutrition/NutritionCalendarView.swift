//
//  NutritionCalendarView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/30.
//

import SwiftUI
import SwiftData

struct NutritionCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization
    @Environment(ThemeManager.self) private var themeManager

    @Query(sort: \NutritionPlan.startDate, order: .reverse)
    private var allPlans: [NutritionPlan]

    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingAddPlan = false

    private var activePlan: NutritionPlan? {
        allPlans.first { $0.isActive }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 计划选择器
                if let plan = activePlan {
                    planHeaderView(plan: plan)
                } else {
                    noPlanView
                }

                Divider()

                // 月历视图
                CalendarMonthView(
                    currentMonth: $currentMonth,
                    selectedDate: $selectedDate,
                    nutritionPlan: activePlan
                )
                .padding()

                Divider()

                // 当日详情
                if let plan = activePlan {
                    DailyMealSummaryView(
                        date: selectedDate,
                        nutritionPlan: plan
                    )
                } else {
                    Spacer()
                }
            }
            .navigationTitle(localization.text(english: "Nutrition", chinese: "营养"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddPlan = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPlan) {
                CreateNutritionPlanView()
            }
        }
    }

    private func planHeaderView(plan: NutritionPlan) -> some View {
        VStack(spacing: 8) {
            Text(plan.name)
                .font(.headline)

            HStack(spacing: 16) {
                Label("\(Int(plan.dailyCalorieTarget)) kcal", systemImage: "flame.fill")
                    .font(.subheadline)
                    .foregroundStyle(.orange)

                if let protein = plan.proteinTargetGrams {
                    Label("\(Int(protein))g", systemImage: "p.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }

                if let carbs = plan.carbsTargetGrams {
                    Label("\(Int(carbs))g", systemImage: "c.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }

                if let fat = plan.fatTargetGrams {
                    Label("\(Int(fat))g", systemImage: "f.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.purple)
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(themeManager.theme.cardBackground)
    }

    private var noPlanView: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text(localization.text(english: "No Active Nutrition Plan", chinese: "没有活跃的饮食计划"))
                .font(.headline)

            Button {
                showingAddPlan = true
            } label: {
                Text(localization.text(english: "Create Plan", chinese: "创建计划"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(themeManager.theme.cardBackground)
    }
}

// MARK: - Calendar Month View

struct CalendarMonthView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    let nutritionPlan: NutritionPlan?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    private var monthDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date] = []
        var date = monthFirstWeek.start

        while date < monthInterval.end {
            days.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }

        return days
    }

    var body: some View {
        VStack(spacing: 16) {
            // 月份导航
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(currentMonth, format: .dateTime.year().month(.wide))
                    .font(.headline)

                Spacer()

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            // 星期标题
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // 日期网格
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(monthDays, id: \.self) { date in
                    NutritionDayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        nutritionPlan: nutritionPlan
                    )
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
        }
    }

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

// MARK: - Nutrition Day Cell

struct NutritionDayCell: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let nutritionPlan: NutritionPlan?

    private var statusColor: Color {
        guard let plan = nutritionPlan else { return .gray }

        let deviation = plan.deviationPercentage(for: date)

        if deviation >= 100 {
            return .gray // 未记录
        } else if deviation <= 10 {
            return .green // 达标
        } else if deviation <= 20 {
            return .yellow // 偏差较小
        } else {
            return .red // 偏差较大
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 16))
                .foregroundStyle(isCurrentMonth ? .primary : .secondary)
                .opacity(isCurrentMonth ? 1 : 0.5)

            // 状态指示器
            if nutritionPlan != nil {
                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    NutritionCalendarView()
        .modelContainer(for: NutritionPlan.self, inMemory: true)
}
