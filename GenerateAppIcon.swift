#!/usr/bin/env swift

import Foundation
import AppKit
import SwiftUI

// This script generates the app icon programmatically
// Run with: swift GenerateAppIcon.swift

let iconSize: CGFloat = 1024

// Create black background with white barbell
let view = NSHostingView(rootView:
    ZStack {
        Color.black
        VStack(spacing: 20) {
            // Top weight
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .frame(width: 180, height: 120)

            // Bar
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .frame(width: 400, height: 40)

            // Bottom weight
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .frame(width: 180, height: 120)
        }
        .rotationEffect(.degrees(45))
    }
    .frame(width: iconSize, height: iconSize)
)

view.frame = NSRect(x: 0, y: 0, width: iconSize, height: iconSize)

// Render to image
let bitmapRep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
view.cacheDisplay(in: view.bounds, to: bitmapRep)

let image = NSImage(size: NSSize(width: iconSize, height: iconSize))
image.addRepresentation(bitmapRep)

// Save as PNG
if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {

    let outputPath = "/Users/christopher/heyuxuan_prjs/Xcode/WorkOutNow/WorkOutNow/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
    try? pngData.write(to: URL(fileURLWithPath: outputPath))
    print("Icon generated at: \(outputPath)")
}
