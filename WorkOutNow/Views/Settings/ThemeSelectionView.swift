//
//  ThemeSelectionView.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/29.
//

import SwiftUI

struct ThemeSelectionView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(LocalizationManager.self) private var localization

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 基础主题
                VStack(alignment: .leading, spacing: 12) {
                    Text(localization.text(english: "Basic Themes", chinese: "基础主题"))
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach([AppTheme.system, .light, .dark]) { theme in
                            ThemeCard(theme: theme)
                        }
                    }
                    .padding(.horizontal)
                }

                // 彩色主题
                VStack(alignment: .leading, spacing: 12) {
                    Text(localization.text(english: "Color Themes", chinese: "彩色主题"))
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach([AppTheme.blue, .purple, .pink, .green, .orange, .red]) { theme in
                            ThemeCard(theme: theme)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(localization.text(english: "Choose Theme", chinese: "选择主题"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ThemeCard: View {
    let theme: AppTheme
    @Environment(ThemeManager.self) private var themeManager
    @Environment(LocalizationManager.self) private var localization

    var isSelected: Bool {
        themeManager.theme == theme
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                themeManager.theme = theme
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    // 主题预览
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.backgroundColor)
                        .frame(height: 120)
                        .overlay(
                            VStack(spacing: 8) {
                                Text(theme.emoji)
                                    .font(.system(size: 40))

                                // 小预览卡片
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(theme.primaryColor)
                                        .frame(width: 20, height: 20)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(theme.cardBackground)
                                        .frame(width: 40, height: 20)
                                }
                            }
                        )

                    // 选中标记
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.white)
                                    .font(.title2)
                                    .shadow(radius: 2)
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }
                }

                // 主题名称
                Text(localization.language == .chinese ?
                     theme.displayName.chinese :
                     theme.displayName.english)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? theme.primaryColor : .primary)
            }
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 3)
        )
    }
}
