//
//  VideoLinksSection.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import SwiftUI

struct VideoLinksSection: View {
    let youtubeURL: String?
    let bilibiliURL: String?
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        VStack(spacing: 12) {
            // Chinese mode: Bilibili first
            if localization.language == .chinese {
                bilibiliLink
                youtubeLink
            } else {
                // English mode: YouTube first
                youtubeLink
                bilibiliLink
            }
        }
    }

    @ViewBuilder
    private var youtubeLink: some View {
        if let youtube = youtubeURL {
            Link(destination: URL(string: "https://youtube.com/watch?v=\(youtube)")!) {
                HStack {
                    Image(systemName: "play.rectangle.fill")
                    Text(localization.text(english: "Watch on YouTube", chinese: "观看YouTube"))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundStyle(.red)
                .cornerRadius(10)
            }
        }
    }

    @ViewBuilder
    private var bilibiliLink: some View {
        if let bilibili = bilibiliURL {
            Link(destination: URL(string: "https://bilibili.com/video/\(bilibili)")!) {
                HStack {
                    Image(systemName: "play.rectangle.fill")
                    Text(localization.text(english: "Watch on Bilibili", chinese: "观看B站教程"))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .padding()
                .background(Color.cyan.opacity(0.1))
                .foregroundStyle(.cyan)
                .cornerRadius(10)
            }
        }
    }
}
