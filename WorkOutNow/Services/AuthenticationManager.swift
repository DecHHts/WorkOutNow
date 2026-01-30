//
//  AuthenticationManager.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/30.
//

import Foundation
import AuthenticationServices
import SwiftUI

@MainActor
@Observable
class AuthenticationManager: NSObject {
    var isAuthenticated: Bool = false
    var userIdentifier: String?
    var fullName: String?
    var email: String?
    var errorMessage: String?

    private let userDefaults = UserDefaults.standard
    private let userIdentifierKey = "userIdentifier"

    override init() {
        super.init()
        checkAuthenticationState()
    }

    // MARK: - Authentication State

    func checkAuthenticationState() {
        guard let userIdentifier = userDefaults.string(forKey: userIdentifierKey) else {
            isAuthenticated = false
            return
        }

        self.userIdentifier = userIdentifier

        // 验证凭证状态
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userIdentifier) { state, error in
            Task { @MainActor in
                switch state {
                case .authorized:
                    self.isAuthenticated = true
                case .revoked, .notFound:
                    self.signOut()
                default:
                    break
                }
            }
        }
    }

    // MARK: - Sign In

    func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user

                // 保存用户信息
                self.userIdentifier = userIdentifier
                userDefaults.set(userIdentifier, forKey: userIdentifierKey)

                // 获取用户信息（首次登录时可用）
                if let fullName = appleIDCredential.fullName {
                    let nameComponents = [
                        fullName.givenName,
                        fullName.familyName
                    ].compactMap { $0 }

                    if !nameComponents.isEmpty {
                        self.fullName = nameComponents.joined(separator: " ")
                        userDefaults.set(self.fullName, forKey: "fullName")
                    }
                }

                if let email = appleIDCredential.email {
                    self.email = email
                    userDefaults.set(email, forKey: "email")
                }

                isAuthenticated = true
                errorMessage = nil
            }

        case .failure(let error):
            let authError = error as NSError

            // 用户取消登录不显示错误
            if authError.code == ASAuthorizationError.canceled.rawValue {
                errorMessage = nil
            } else {
                errorMessage = "登录失败: \(error.localizedDescription)"
            }

            isAuthenticated = false
        }
    }

    // MARK: - Sign Out

    func signOut() {
        userDefaults.removeObject(forKey: userIdentifierKey)
        userDefaults.removeObject(forKey: "fullName")
        userDefaults.removeObject(forKey: "email")

        userIdentifier = nil
        fullName = nil
        email = nil
        isAuthenticated = false
    }

    // MARK: - User Info

    func loadStoredUserInfo() {
        fullName = userDefaults.string(forKey: "fullName")
        email = userDefaults.string(forKey: "email")
    }
}
