# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WorkOutNow is a SwiftUI-based iOS/iPadOS application using SwiftData for data persistence. The app targets iOS 26.2+ with Swift 5.0.

## Build and Test Commands

### Building
```bash
# Build the project
xcodebuild -scheme WorkOutNow -configuration Debug build

# Build for release
xcodebuild -scheme WorkOutNow -configuration Release build
```

### Testing
```bash
# Run all tests
xcodebuild test -scheme WorkOutNow -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test target
xcodebuild test -scheme WorkOutNow -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:WorkOutNowTests

# Run UI tests
xcodebuild test -scheme WorkOutNow -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:WorkOutNowUITests
```

### Opening in Xcode
```bash
open WorkOutNow.xcodeproj
```

## Architecture

### Data Layer - SwiftData
The app uses SwiftData as its persistence framework:
- **Model Container**: Configured in `WorkOutNowApp.swift` with a shared `ModelContainer` instance
- **Schema**: Defined in the app entry point and includes all `@Model` classes
- **Configuration**: Uses persistent storage (not in-memory) by default
- **Models**: Located in the root `WorkOutNow/` directory, decorated with `@Model` macro

### View Layer - SwiftUI
- **App Entry**: `WorkOutNowApp.swift` - Sets up the model container and provides it to the view hierarchy via `.modelContainer()`
- **Main View**: `ContentView.swift` - Demonstrates SwiftData integration with `@Query` for reactive data fetching and `@Environment(\.modelContext)` for mutations
- **Pattern**: Uses `NavigationSplitView` for adaptive layout across iPhone and iPad

### Current Data Model
- **Item.swift**: Simple timestamp-based model serving as a template/example

### Swift Concurrency
The project uses:
- `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` - All code defaults to running on the main actor

### Testing Framework
Uses Swift Testing (not XCTest) - note the `import Testing` and `@Test` syntax in test files.

## Key Capabilities
- Remote notifications enabled (see Info.plist `UIBackgroundModes`)
- Universal app supporting iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`)
- String catalog generation enabled for localization (`STRING_CATALOG_GENERATE_SYMBOLS = YES`)

## Project Structure
```
WorkOutNow/                  # Main app target
├── WorkOutNowApp.swift      # App entry point, SwiftData setup
├── ContentView.swift        # Main view
├── Item.swift              # SwiftData models
├── Assets.xcassets/        # App assets
├── Info.plist              # App capabilities
└── WorkOutNow.entitlements

WorkOutNowTests/            # Unit tests (Swift Testing)
WorkOutNowUITests/          # UI tests
```
