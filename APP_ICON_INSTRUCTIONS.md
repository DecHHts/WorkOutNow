# App Icon Creation Instructions

## Quick Setup

The app icon needs to be created manually. Here are three options:

### Option 1: Use SF Symbols App (Easiest)
1. Open the SF Symbols app on your Mac
2. Search for "figure.strengthtraining.traditional"
3. Export as 1024x1024 PNG with:
   - Black background (#000000)
   - White foreground (#FFFFFF)
4. Save as `AppIcon-1024.png` and `AppIcon-tinted.png`
5. Place in: `WorkOutNow/Assets.xcassets/AppIcon.appiconset/`

### Option 2: Use Figma/Sketch
1. Create 1024x1024 artboard with black background
2. Draw simple barbell:
   - Two circular weights on each end (white)
   - Straight bar connecting them (white)
3. Export as PNG: `AppIcon-1024.png` and `AppIcon-tinted.png`
4. Place in: `WorkOutNow/Assets.xcassets/AppIcon.appiconset/`

### Option 3: Use Online Icon Generator
1. Go to https://www.appicon.co/ or similar
2. Upload a simple barbell icon design
3. Generate iOS icon set
4. Extract 1024x1024 versions
5. Place in: `WorkOutNow/Assets.xcassets/AppIcon.appiconset/`

## Required Files
- `AppIcon-1024.png` - Main icon (white barbell on black)
- `AppIcon-tinted.png` - Monochrome version for tinted appearance

## Design Specifications
- **Size**: 1024x1024 pixels
- **Background**: Black (#000000)
- **Foreground**: White (#FFFFFF)
- **Style**: Minimalist, clean lines
- **Subject**: Barbell icon (simple representation)
- **Format**: PNG with no transparency

## Temporary Workaround
For development/testing, Xcode will use a default placeholder icon if the PNG files are missing. The app will still build and run.
