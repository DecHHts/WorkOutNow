//
//  SignInWithAppleView.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/30.
//

import SwiftUI
import AuthenticationServices

struct SignInWithAppleView: View {
    @Environment(AuthenticationManager.self) private var authManager
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Logo或Icon
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)

            // 应用名称
            Text("WorkOutNow")
                .font(.largeTitle)
                .fontWeight(.bold)

            // 欢迎文本
            Text(localization.text(english: "Track your fitness journey", chinese: "记录您的健身之旅"))
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            // Sign in with Apple按钮
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    authManager.handleSignInWithApple(result: result)
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal, 40)

            // 错误信息
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            // 继续按钮（暂时跳过登录）
            Button {
                // 临时跳过登录，直接进入应用
                authManager.isAuthenticated = true
            } label: {
                Text(localization.text(english: "Skip for now", chinese: "暂时跳过"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 20)

            // 隐私说明
            Text(localization.text(
                english: "By continuing, you agree to our Privacy Policy",
                chinese: "继续即表示您同意我们的隐私政策"
            ))
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    SignInWithAppleView()
        .environment(AuthenticationManager())
        .environment(LocalizationManager())
}
