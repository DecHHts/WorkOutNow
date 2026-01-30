//
//  UserProfileView.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/29.
//

import SwiftUI
import SwiftData

struct UserProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocalizationManager.self) private var localization
    @Query private var profiles: [UserProfile]

    private var userProfile: UserProfile? {
        profiles.first
    }

    @State private var birthday: Date = Date()
    @State private var selectedGender: Gender = .preferNotToSay
    @State private var heightCm: Double = 170
    @State private var weightKg: Double = 70

    var body: some View {
        Form {
            Section(header: Text(localization.text(english: "Personal Info", chinese: "个人信息"))) {
                if let profile = userProfile {
                    Text(profile.fullName ?? localization.text(english: "No name", chinese: "未设置"))
                        .foregroundStyle(.secondary)
                }

                DatePicker(
                    localization.text(english: "Birthday", chinese: "生日"),
                    selection: $birthday,
                    displayedComponents: .date
                )

                Picker(localization.text(english: "Gender", chinese: "性别"), selection: $selectedGender) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Text(localization.language == .chinese ? gender.chineseName : gender.rawValue).tag(gender)
                    }
                }
            }

            Section(header: Text(localization.text(english: "Body Metrics", chinese: "身体数据"))) {
                HStack {
                    Text(localization.text(english: "Height", chinese: "身高"))
                    Spacer()
                    TextField("170", value: $heightCm, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("cm")
                }

                HStack {
                    Text(localization.text(english: "Weight", chinese: "体重"))
                    Spacer()
                    TextField("70", value: $weightKg, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("kg")
                }
            }

            Button(localization.text(english: "Save", chinese: "保存")) {
                saveProfile()
            }
        }
        .navigationTitle(localization.text(english: "Profile", chinese: "个人资料"))
        .onAppear {
            loadProfile()
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private func loadProfile() {
        guard let profile = userProfile else { return }
        birthday = profile.birthday ?? Date()
        selectedGender = profile.gender
        heightCm = profile.heightCm ?? 170
        weightKg = profile.weightKg ?? 70
    }

    private func saveProfile() {
        guard let profile = userProfile else { return }
        profile.birthday = birthday
        profile.gender = selectedGender
        profile.heightCm = heightCm
        profile.weightKg = weightKg
        profile.updatedAt = Date()

        try? modelContext.save()
    }
}
