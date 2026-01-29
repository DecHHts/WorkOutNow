//
//  PlanCalendarView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI
import SwiftData

struct PlanCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization
    @Environment(ThemeManager.self) private var themeManager
    @Query(filter: #Predicate<TrainingPlan> { $0.isActive }, sort: \TrainingPlan.name) private var activePlans: [TrainingPlan]
    @Query(sort: \WorkoutLog.date, order: .reverse) private var workoutLogs: [WorkoutLog]
    @Query private var planCompletions: [PlanCompletion]

    @State private var selectedDate = Date()
    @State private var currentMonth = Date()

    private var calendar: Calendar {
        Calendar.current
    }

    private var activePlan: TrainingPlan? {
        activePlans.first
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let plan = activePlan {
                    // 固定的日历部分
                    VStack(spacing: 0) {
                        PlanCalendarGridView(
                            selectedDate: $selectedDate,
                            currentMonth: $currentMonth,
                            plan: plan,
                            workoutLogs: workoutLogs,
                            planCompletions: planCompletions,
                            modelContext: modelContext
                        )
                        .padding()

                        Divider()
                    }

                    // 可滚动的详情部分
                    PlanDayDetailView(
                        date: selectedDate,
                        plan: plan,
                        workoutLogs: workoutLogs,
                        planCompletions: planCompletions,
                        modelContext: modelContext
                    )
                } else {
                    ContentUnavailableView(
                        localization.text(english: "No Active Plan", chinese: "无激活的训练计划"),
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text(localization.text(english: "Create and activate a plan in the Plans tab", chinese: "请在训练计划标签页创建并激活一个计划"))
                    )
                }
            }
            .background(themeManager.theme.backgroundColor.ignoresSafeArea())
            .navigationTitle(localization.text(english: "Plan Calendar", chinese: "计划日历"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(themeManager.theme.backgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct PlanCalendarGridView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    let plan: TrainingPlan
    let workoutLogs: [WorkoutLog]
    let planCompletions: [PlanCompletion]
    let modelContext: ModelContext

    private var calendar: Calendar {
        Calendar.current
    }

    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月 MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)
        }
    }

    private var paddingDays: Int {
        guard let firstDay = daysInMonth.first else { return 0 }
        return calendar.component(.weekday, from: firstDay) - 1
    }

    private func getCompletion(for date: Date) -> PlanCompletion? {
        let startOfDay = calendar.startOfDay(for: date)
        return planCompletions.first {
            calendar.isDate($0.date, inSameDayAs: startOfDay) && $0.planId == plan.id
        }
    }

    private func getWorkout(for date: Date) -> WorkoutLog? {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return workoutLogs.first { log in
            log.date >= startOfDay && log.date < endOfDay
        }
    }

    private func getDayStatus(for date: Date) -> CalendarDayStatus {
        let completion = getCompletion(for: date)
        return CalendarColorCoder.status(for: date, plan: plan, completion: completion)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(monthYearText)
                    .font(.headline)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }

                ForEach(0..<paddingDays, id: \.self) { _ in
                    Color.clear
                        .frame(height: 40)
                }

                ForEach(daysInMonth, id: \.self) { date in
                    PlanDayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        status: getDayStatus(for: date),
                        cycleDay: PlanCalculator.cycleDay(for: date, plan: plan),
                        action: { selectedDate = date }
                    )
                }
            }

            LegendView()
        }
    }

    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

struct PlanDayCell: View {
    let date: Date
    let isSelected: Bool
    let status: CalendarDayStatus
    let cycleDay: Int
    let action: () -> Void

    private var calendar: Calendar {
        Calendar.current
    }

    private var isToday: Bool {
        calendar.isDateInToday(date)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14))
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)

                if cycleDay > 0 {
                    Text("D\(cycleDay)")
                        .font(.system(size: 8))
                        .foregroundColor(isSelected ? .white : .secondary)
                }
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor : CalendarColorCoder.color(for: status))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct LegendView: View {
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localization.text(english: "Legend", chinese: "图例"))
                .font(.caption)
                .fontWeight(.bold)

            HStack(spacing: 16) {
                LegendItem(color: .green, text: localization.text(english: "Complete", chinese: "完成"))
                LegendItem(color: .yellow, text: localization.text(english: "Partial", chinese: "部分"))
                LegendItem(color: .red, text: localization.text(english: "Missed", chinese: "未完成"))
                LegendItem(color: .blue.opacity(0.5), text: localization.text(english: "Rest", chinese: "休息"))
                LegendItem(color: .gray.opacity(0.3), text: localization.text(english: "Future", chinese: "未来"))
            }
        }
        .font(.caption2)
    }
}

struct LegendItem: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(text)
        }
    }
}

struct PlanDayDetailView: View {
    let date: Date
    let plan: TrainingPlan
    let workoutLogs: [WorkoutLog]
    let planCompletions: [PlanCompletion]
    let modelContext: ModelContext
    @Environment(LocalizationManager.self) private var localization

    private var calendar: Calendar {
        Calendar.current
    }

    private var dayTemplate: DayTemplate? {
        PlanCalculator.template(for: date, plan: plan)
    }

    private var workout: WorkoutLog? {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return workoutLogs.first { log in
            log.date >= startOfDay && log.date < endOfDay
        }
    }

    private var completion: PlanCompletion {
        CompletionCalculator.calculateCompletion(
            date: date,
            plan: plan,
            workoutLog: workout,
            modelContext: modelContext
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(date, style: .date)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(localization.text(english: "Day \(PlanCalculator.cycleDay(for: date, plan: plan))", chinese: "第\(PlanCalculator.cycleDay(for: date, plan: plan))天"))
                        .font(.headline)
                        .foregroundColor(.secondary)

                    if let template = dayTemplate, let name = template.name {
                        Text(name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                if let template = dayTemplate {
                    if template.isRestDay {
                        HStack {
                            Image(systemName: "moon.zzz.fill")
                            Text(localization.text(english: "Rest Day", chinese: "休息日"))
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(localization.text(english: "Planned Exercises", chinese: "计划训练"))
                                .font(.headline)
                                .padding(.horizontal)

                            if let exercises = template.exercises?.sorted(by: { $0.order < $1.order }), !exercises.isEmpty {
                                ForEach(exercises) { planExercise in
                                    if let exercise = planExercise.exercise {
                                        PlannedExerciseRow(
                                            exercise: exercise,
                                            planExercise: planExercise,
                                            isCompleted: completion.completedExerciseIds.contains(exercise.id)
                                        )
                                    }
                                }
                            } else {
                                Text(localization.text(english: "No exercises planned for this day", chinese: "该日无训练安排"))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if completion.completionPercentage > 0 {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(localization.text(english: "Completion", chinese: "完成度"))
                                        .font(.headline)
                                        .padding(.horizontal)

                                    ProgressView(value: completion.completionPercentage)
                                        .padding(.horizontal)

                                    Text("\(Int(completion.completionPercentage * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
        }
    }
}

struct PlannedExerciseRow: View {
    let exercise: Exercise
    let planExercise: PlanExercise
    let isCompleted: Bool
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.displayName(language: localization.language))
                    .font(.headline)

                HStack(spacing: 12) {
                    Text(localization.text(english: "\(planExercise.targetSets) sets", chinese: "\(planExercise.targetSets)组"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("×")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(localization.text(english: "\(planExercise.targetReps) reps", chinese: "\(planExercise.targetReps)次"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(isCompleted ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

#Preview {
    PlanCalendarView()
        .modelContainer(for: TrainingPlan.self, inMemory: true)
}
