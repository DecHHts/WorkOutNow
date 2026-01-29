//
//  WorkoutCalendarView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI
import SwiftData

struct WorkoutCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization
    @Environment(ThemeManager.self) private var themeManager
    @Query(sort: \WorkoutLog.date, order: .reverse) private var workoutLogs: [WorkoutLog]

    @State private var selectedDate = Date()
    @State private var showingLogWorkout = false

    private var calendar: Calendar {
        Calendar.current
    }

    private var selectedDateWorkout: WorkoutLog? {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return workoutLogs.first { log in
            log.date >= startOfDay && log.date < endOfDay
        }
    }

    private var isSelectedDateToday: Bool {
        calendar.isDateInToday(selectedDate)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 固定的日历部分
                VStack(spacing: 0) {
                    CalendarGridView(
                        selectedDate: $selectedDate,
                        workoutLogs: workoutLogs
                    )
                    .padding()

                    Divider()
                }

                // 可滚动的详情部分
                ScrollView {
                    VStack(spacing: 16) {
                        // 今日训练计划（仅当选中今天时显示）
                        if isSelectedDateToday {
                            TodayTrainingPlanView(
                                date: selectedDate,
                                showingLogWorkout: $showingLogWorkout
                            )
                            .padding()
                        }

                        // 训练详情
                        WorkoutDetailView(
                            date: selectedDate,
                            workout: selectedDateWorkout
                        )
                    }
                }
            }
            .background(themeManager.theme.backgroundColor.ignoresSafeArea())
            .navigationTitle(localization.text(english: "Workout Calendar", chinese: "训练日历"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(themeManager.theme.backgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingLogWorkout = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingLogWorkout) {
                LogWorkoutView(date: selectedDate)
            }
        }
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    let workoutLogs: [WorkoutLog]

    @State private var currentMonth = Date()

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

    private func hasWorkout(on date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return workoutLogs.contains { log in
            log.date >= startOfDay && log.date < endOfDay
        }
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
                    DayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        hasWorkout: hasWorkout(on: date),
                        action: { selectedDate = date }
                    )
                }
            }
        }
    }

    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasWorkout: Bool
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
                    .font(.system(size: 16))
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)

                if hasWorkout {
                    Circle()
                        .fill(isSelected ? Color.white : Color.accentColor)
                        .frame(width: 4, height: 4)
                } else {
                    Color.clear.frame(width: 4, height: 4)
                }
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct WorkoutDetailView: View {
    let date: Date
    let workout: WorkoutLog?
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(date, style: .date)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top)

            if let workout = workout {
                    VStack(alignment: .leading, spacing: 12) {
                        if let duration = workout.duration {
                            HStack {
                                Image(systemName: "clock")
                                Text(localization.text(english: "Duration: \(Int(duration / 60)) min", chinese: "时长: \(Int(duration / 60))分钟"))
                            }
                            .padding(.horizontal)
                        }

                        if let intensity = workout.intensityRating {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text(localization.text(english: "Intensity: \(intensity)/10", chinese: "强度: \(intensity)/10"))
                            }
                            .padding(.horizontal)
                        }

                        if let notes = workout.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localization.text(english: "Notes", chinese: "备注"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(notes)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }

                        Divider()
                            .padding(.horizontal)

                        Text(localization.text(english: "Exercises", chinese: "训练详情"))
                            .font(.headline)
                            .padding(.horizontal)

                        if let sets = workout.sets {
                            let groupedSets = Dictionary(grouping: sets) { $0.exercise?.id }

                            ForEach(Array(groupedSets.keys.compactMap { $0 }), id: \.self) { exerciseId in
                                if let exerciseSets = groupedSets[exerciseId],
                                   let exercise = exerciseSets.first?.exercise {
                                    ExerciseSetGroup(exercise: exercise, sets: exerciseSets)
                                }
                            }
                        }
                    }
                } else {
                    Text(localization.text(english: "No workout logged for this date", chinese: "该日期无训练记录"))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
    }

struct ExerciseSetGroup: View {
    let exercise: Exercise
    let sets: [WorkoutSet]
    @Environment(LocalizationManager.self) private var localization

    var sortedSets: [WorkoutSet] {
        sets.sorted { $0.setNumber < $1.setNumber }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.displayName(language: localization.language))
                    .font(.headline)
            }
            .padding(.horizontal)

            ForEach(sortedSets) { set in
                HStack {
                    Text(localization.text(english: "Set \(set.setNumber)", chinese: "第\(set.setNumber)组"))
                        .frame(width: 100, alignment: .leading)

                    if let weight = set.weightKg {
                        Text("\(String(format: "%.1f", weight)) kg")
                            .fontWeight(.semibold)
                    }

                    Text("× \(set.reps)")
                        .fontWeight(.semibold)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

#Preview {
    WorkoutCalendarView()
        .modelContainer(for: WorkoutLog.self, inMemory: true)
}
