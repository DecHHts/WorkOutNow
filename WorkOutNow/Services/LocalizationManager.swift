//
//  LocalizationManager.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/29.
//

import SwiftUI
import Combine

enum AppLanguage: String, Codable, CaseIterable {
    case chinese = "zh"
    case english = "en"

    var displayName: String {
        switch self {
        case .chinese: return "中文"
        case .english: return "English"
        }
    }
}

@Observable
class LocalizationManager {
    // 使用私有存储属性 + 公开计算属性来确保Observable触发更新
    private var _language: AppLanguage {
        didSet {
            UserDefaults.standard.set(_language.rawValue, forKey: "appLanguage")
            objectWillChange.send()
        }
    }

    let objectWillChange = PassthroughSubject<Void, Never>()

    var language: AppLanguage {
        get { _language }
        set {
            _language = newValue
        }
    }

    init() {
        if let rawValue = UserDefaults.standard.string(forKey: "appLanguage"),
           let savedLanguage = AppLanguage(rawValue: rawValue) {
            _language = savedLanguage
        } else {
            _language = .english
        }
    }

    func text(english: String, chinese: String) -> String {
        language == .chinese ? chinese : english
    }

    func muscleGroupName(_ group: MuscleGroup) -> String {
        language == .chinese ? group.chineseName : group.rawValue
    }
}
