//
//  ThemeManager.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/29.
//

import SwiftUI
import Combine

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    case blue = "blue"
    case purple = "purple"
    case pink = "pink"
    case green = "green"
    case orange = "orange"
    case red = "red"

    var id: String { rawValue }

    var displayName: (english: String, chinese: String) {
        switch self {
        case .system: return ("Follow System", "跟随系统")
        case .light: return ("Light", "浅色")
        case .dark: return ("Dark", "深色")
        case .blue: return ("Ocean Blue", "海洋蓝")
        case .purple: return ("Mystic Purple", "神秘紫")
        case .pink: return ("Sweet Pink", "甜心粉")
        case .green: return ("Forest Green", "森林绿")
        case .orange: return ("Sunset Orange", "日落橙")
        case .red: return ("Energy Red", "活力红")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark, .blue, .purple, .pink, .green, .orange, .red: return .dark
        }
    }

    var primaryColor: Color {
        switch self {
        case .system, .light, .dark: return .accentColor
        case .blue: return Color(red: 0.2, green: 0.6, blue: 0.9)
        case .purple: return Color(red: 0.6, green: 0.3, blue: 0.9)
        case .pink: return Color(red: 0.95, green: 0.4, blue: 0.7)
        case .green: return Color(red: 0.2, green: 0.8, blue: 0.5)
        case .orange: return Color(red: 0.95, green: 0.6, blue: 0.2)
        case .red: return Color(red: 0.9, green: 0.2, blue: 0.3)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .system, .light: return Color(.systemBackground)
        case .dark: return Color(.black)
        case .blue: return Color(red: 0.05, green: 0.1, blue: 0.2)
        case .purple: return Color(red: 0.15, green: 0.05, blue: 0.2)
        case .pink: return Color(red: 0.2, green: 0.05, blue: 0.15)
        case .green: return Color(red: 0.05, green: 0.15, blue: 0.1)
        case .orange: return Color(red: 0.2, green: 0.1, blue: 0.05)
        case .red: return Color(red: 0.2, green: 0.05, blue: 0.05)
        }
    }

    var cardBackground: Color {
        switch self {
        case .system, .light: return Color(.secondarySystemBackground)
        case .dark: return Color(white: 0.15)
        case .blue: return Color(red: 0.1, green: 0.2, blue: 0.35)
        case .purple: return Color(red: 0.25, green: 0.15, blue: 0.35)
        case .pink: return Color(red: 0.3, green: 0.15, blue: 0.25)
        case .green: return Color(red: 0.1, green: 0.25, blue: 0.2)
        case .orange: return Color(red: 0.3, green: 0.2, blue: 0.15)
        case .red: return Color(red: 0.3, green: 0.15, blue: 0.15)
        }
    }

    var emoji: String {
        switch self {
        case .system: return "⚙️"
        case .light: return "☀️"
        case .dark: return "🌙"
        case .blue: return "🌊"
        case .purple: return "🔮"
        case .pink: return "💖"
        case .green: return "🌲"
        case .orange: return "🌅"
        case .red: return "❤️"
        }
    }
}

@Observable
class ThemeManager {
    private var _theme: AppTheme {
        didSet {
            UserDefaults.standard.set(_theme.rawValue, forKey: "appTheme")
            objectWillChange.send()
        }
    }

    let objectWillChange = PassthroughSubject<Void, Never>()

    var theme: AppTheme {
        get { _theme }
        set { _theme = newValue }
    }

    init() {
        if let rawValue = UserDefaults.standard.string(forKey: "appTheme"),
           let savedTheme = AppTheme(rawValue: rawValue) {
            _theme = savedTheme
        } else {
            _theme = .system
        }
    }
}
