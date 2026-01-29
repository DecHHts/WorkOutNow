//
//  BodyMetricsView.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/29.
//

import SwiftUI
import SwiftData
import Charts

struct BodyMetricsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization
    @Query(sort: \BodyMetric.date, order: .reverse) private var metrics: [BodyMetric]

    @State private var showingAddMetric = false

    var body: some View {
        NavigationStack {
            List {
                if !metrics.isEmpty {
                    Section(header: Text(localization.text(english: "Weight Trend", chinese: "体重趋势"))) {
                        Chart(metrics.prefix(12)) { metric in
                            LineMark(
                                x: .value("Date", metric.date),
                                y: .value("Weight", metric.weightKg ?? 0)
                            )
                            .foregroundStyle(.blue)
                        }
                        .frame(height: 200)
                    }
                }

                Section(header: Text(localization.text(english: "History", chinese: "历史记录"))) {
                    ForEach(metrics) { metric in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(metric.date, style: .date)
                                .font(.headline)
                            HStack {
                                if let weight = metric.weightKg {
                                    Text(localization.text(english: "Weight", chinese: "体重") + ": \(String(format: "%.1f", weight)) kg")
                                }
                                if let bodyFat = metric.bodyFatPercentage {
                                    Text(localization.text(english: "Body Fat", chinese: "体脂") + ": \(String(format: "%.1f", bodyFat))%")
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: deleteMetrics)
                }
            }
            .navigationTitle(localization.text(english: "Body Metrics", chinese: "身体数据"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMetric = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMetric) {
                AddBodyMetricView()
            }
        }
    }

    private func deleteMetrics(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(metrics[index])
        }
    }
}

struct AddBodyMetricView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var localization

    @State private var date = Date()
    @State private var weightKg: Double = 70
    @State private var bodyFatPercentage: Double = 20
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker(localization.text(english: "Date", chinese: "日期"), selection: $date, displayedComponents: .date)

                HStack {
                    Text(localization.text(english: "Weight (kg)", chinese: "体重 (kg)"))
                    Spacer()
                    TextField("70", value: $weightKg, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text(localization.text(english: "Body Fat %", chinese: "体脂率 %"))
                    Spacer()
                    TextField("20", value: $bodyFatPercentage, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }

                TextField(localization.text(english: "Notes", chinese: "备注"), text: $notes)
            }
            .navigationTitle(localization.text(english: "Add Metric", chinese: "添加数据"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.text(english: "Cancel", chinese: "取消")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.text(english: "Save", chinese: "保存")) {
                        saveMetric()
                    }
                }
            }
        }
    }

    private func saveMetric() {
        let metric = BodyMetric(
            date: date,
            weightKg: weightKg,
            bodyFatPercentage: bodyFatPercentage,
            notes: notes.isEmpty ? nil : notes
        )
        modelContext.insert(metric)
        dismiss()
    }
}
