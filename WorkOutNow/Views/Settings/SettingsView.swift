//
//  SettingsView.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/29.
//

import SwiftUI

struct SettingsView: View {
    @Environment(LocalizationManager.self) private var localization
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        NavigationStack {
            List {
                // 主题设置
                Section(header: Text(localization.text(english: "Theme", chinese: "主题"))) {
                    NavigationLink(destination: ThemeSelectionView().toolbar(.hidden, for: .tabBar)) {
                        HStack {
                            Text(themeManager.theme.emoji)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text(localization.text(english: "App Theme", chinese: "应用主题"))
                                Text(localization.language == .chinese ?
                                     themeManager.theme.displayName.chinese :
                                     themeManager.theme.displayName.english)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section(header: Text(localization.text(english: "Language", chinese: "语言"))) {
                    Picker(localization.text(english: "App Language", chinese: "应用语言"), selection: Binding(
                        get: { localization.language },
                        set: { newValue in
                            print("🌐 Language changing from \(localization.language.rawValue) to \(newValue.rawValue)")
                            localization.language = newValue
                            print("🌐 Language changed, new value: \(localization.language.rawValue)")
                        }
                    )) {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text(localization.text(english: "Profile", chinese: "个人资料"))) {
                    NavigationLink(destination: UserProfileView().toolbar(.hidden, for: .tabBar)) {
                        Text(localization.text(english: "Edit Profile", chinese: "编辑资料"))
                    }

                    NavigationLink(destination: BodyMetricsView().toolbar(.hidden, for: .tabBar)) {
                        Text(localization.text(english: "Body Metrics", chinese: "身体数据"))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(themeManager.theme.backgroundColor.ignoresSafeArea())
            .navigationTitle(localization.text(english: "Settings", chinese: "设置"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(themeManager.theme.backgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
