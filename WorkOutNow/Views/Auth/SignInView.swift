//
//  SignInView.swift
//  WorkOutNow
//
//  Created by Christopher on 2026/01/29.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AuthenticationManager.self) private var authManager
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 100))
                .foregroundStyle(.tint)

            VStack(spacing: 16) {
                Text("WorkOutNow")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(localization.text(
                    english: "Track your fitness journey",
                    chinese: "记录您的健身之旅"
                ))
                .font(.headline)
                .foregroundStyle(.secondary)
            }

            SignInWithAppleButton(
                onRequest: { request in
                    let appleRequest = authManager.signInWithApple()
                    request.requestedScopes = appleRequest.requestedScopes
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        authManager.handleSignInResult(authorization)
                    case .failure(let error):
                        authManager.errorMessage = error.localizedDescription
                    }
                }
            )
            .frame(height: 50)
            .padding(.horizontal, 40)

            // 仅在模拟器中显示测试按钮
            #if targetEnvironment(simulator)
            Button(action: {
                print("🔐 Test sign in tapped")
                authManager.currentUserID = "simulator-test-user"
                authManager.isAuthenticated = true
            }) {
                HStack {
                    Image(systemName: "person.circle.fill")
                    Text(localization.text(english: "Simulator Test Sign In", chinese: "模拟器测试登录"))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue.opacity(0.1))
                .foregroundStyle(.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            #endif

            if let error = authManager.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .padding()
    }
}
