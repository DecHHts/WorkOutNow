//
//  AuthenticationManager.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/29.
//

import SwiftUI
import AuthenticationServices
import SwiftData

@Observable
class AuthenticationManager: NSObject {
    var isAuthenticated = false {
        didSet {
            print("🔐 Authentication state changed: \(isAuthenticated)")
        }
    }
    var currentUserID: String?
    var errorMessage: String?

    private var modelContext: ModelContext?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        checkAuthenticationState()
    }

    func signInWithApple() -> ASAuthorizationAppleIDRequest {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        return request
    }

    func handleSignInResult(_ authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Invalid credentials"
            return
        }

        let userID = credential.user
        currentUserID = userID

        // Check if user profile exists
        guard let modelContext = modelContext else { return }

        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { $0.appleUserID == userID }
        )

        if let existingProfile = try? modelContext.fetch(descriptor).first {
            // User exists, sign in
            isAuthenticated = true
        } else {
            // Create new user profile
            let profile = UserProfile(
                appleUserID: userID,
                email: credential.email,
                fullName: [credential.fullName?.givenName, credential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
            )
            modelContext.insert(profile)
            try? modelContext.save()
            isAuthenticated = true
        }

        // Save user ID to UserDefaults for persistence
        UserDefaults.standard.set(userID, forKey: "appleUserID")
    }

    func checkAuthenticationState() {
        guard let userID = UserDefaults.standard.string(forKey: "appleUserID") else {
            isAuthenticated = false
            return
        }

        currentUserID = userID

        // Verify credential state
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userID) { state, error in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    self.isAuthenticated = true
                case .revoked, .notFound:
                    self.signOut()
                default:
                    self.isAuthenticated = false
                }
            }
        }
    }

    func signOut() {
        print("🔐 Signing out...")

        // 清除所有认证状态
        isAuthenticated = false
        currentUserID = nil
        errorMessage = nil
        UserDefaults.standard.removeObject(forKey: "appleUserID")

        print("🔐 Sign out completed. isAuthenticated = \(isAuthenticated)")
    }
}
