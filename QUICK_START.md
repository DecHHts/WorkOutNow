# Quick Start Guide - WorkOutNow

## What Was Implemented

### ✅ Completed Features
1. **Language Toggle** - Pure Chinese OR English (Settings tab)
2. **Video Priority** - Bilibili first (CN) / YouTube first (EN)
3. **Calendar Fix** - Dates before plan no longer show red
4. **Authentication** - Sign in with Apple
5. **User Profiles** - Birthday, gender, height, weight
6. **Body Metrics** - Weekly weight/body fat tracking with charts
7. **iCloud Sync** - CloudKit configuration ready
8. **Settings Tab** - New 5th tab with preferences

### ⚠️ Requires Manual Setup
1. **App Icon** - Create PNG files (see APP_ICON_INSTRUCTIONS.md)
2. **CloudKit** - Configure container in Apple Developer portal
3. **Device Testing** - Sign in with Apple needs physical device

## How to Test

### 1. Build & Run
```bash
cd /Users/christopher/heyuxuan_prjs/Xcode/WorkOutNow
xcodebuild -scheme WorkOutNow -configuration Debug build \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Or open in Xcode:
```bash
open WorkOutNow.xcodeproj
```

### 2. Test Language Switching
1. Run app in simulator
2. Navigate to **Settings tab** (5th tab, gear icon)
3. Toggle language between "English" and "中文"
4. Observe all UI text changes immediately
5. Check exercise names show single language
6. Verify video links reorder (Bilibili first in Chinese)

### 3. Test Calendar Bug Fix
1. Create a training plan with start date = today
2. Go to **Plan Calendar** tab
3. Scroll to dates BEFORE today
4. ✅ Should show **gray** (not red)
5. Scroll to future dates
6. ✅ Should show **gray**
7. Today and past training days should show colors based on completion

### 4. Test Authentication (Physical Device Only)
**Note:** Sign in with Apple does NOT work in simulator
1. Build to physical device or TestFlight
2. Launch app → Should show SignInView
3. Tap "Sign in with Apple" button
4. Complete authentication
5. ✅ App should show main TabView after sign-in
6. Go to Settings → Sign Out → Should return to SignInView

### 5. Test User Profile
1. After signing in, go to **Settings tab**
2. Tap **"Edit Profile" (编辑资料)**
3. Set birthday, gender, height, weight
4. Tap **"Save" (保存)**
5. Kill app and relaunch
6. ✅ Profile data should persist

### 6. Test Body Metrics
1. Settings tab → **"Body Metrics" (身体数据)**
2. Tap **+ button**
3. Enter weight, body fat %, notes
4. Tap **"Save" (保存)**
5. ✅ Entry appears in history
6. Add 5+ entries → Chart appears showing weight trend
7. Swipe to delete entries

## File Structure

```
WorkOutNow/
├── Models/
│   ├── Exercise.swift
│   ├── WorkoutLog.swift
│   ├── TrainingPlan.swift
│   ├── PlanCompletion.swift
│   ├── UserProfile.swift ⭐ NEW
│   └── BodyMetric.swift ⭐ NEW
│
├── Services/
│   ├── LocalizationManager.swift ⭐ NEW
│   ├── AuthenticationManager.swift ⭐ NEW
│   ├── PlanCalculator.swift
│   ├── CompletionCalculator.swift
│   └── CalendarColorCoder.swift (FIXED)
│
├── Views/
│   ├── Auth/ ⭐ NEW
│   │   └── SignInView.swift
│   ├── Profile/ ⭐ NEW
│   │   ├── UserProfileView.swift
│   │   └── BodyMetricsView.swift
│   ├── Settings/ ⭐ NEW
│   │   └── SettingsView.swift
│   ├── Exercises/
│   │   ├── ExerciseDatabaseView.swift (UPDATED)
│   │   ├── ExerciseDetailView.swift (UPDATED)
│   │   └── AddCustomExerciseView.swift (UPDATED)
│   ├── Plans/
│   │   ├── TrainingPlansView.swift (UPDATED)
│   │   ├── CreatePlanView.swift (UPDATED)
│   │   ├── PlanEditorView.swift (UPDATED)
│   │   ├── DayTemplateEditorView.swift (UPDATED)
│   │   └── ExercisePickerView.swift (UPDATED)
│   ├── Calendar/
│   │   ├── WorkoutCalendarView.swift (UPDATED)
│   │   └── PlanCalendarView.swift (UPDATED)
│   └── Workout/
│       └── LogWorkoutView.swift (UPDATED)
│
├── Components/
│   ├── VideoLinksSection.swift (UPDATED)
│   └── MuscleGroupBadge.swift (UPDATED)
│
├── Data/
│   └── ExerciseSeeder.swift
│
├── ContentView.swift (UPDATED - 5 tabs)
├── WorkOutNowApp.swift (UPDATED - Auth + CloudKit)
├── WorkOutNow.entitlements (UPDATED)
└── Info.plist (UPDATED)
```

## Language System Usage

### In Views
```swift
struct MyView: View {
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        Text(localization.text(english: "Hello", chinese: "你好"))
        Text(localization.muscleGroupName(.chest)) // "Chest" or "胸部"
        Text(exercise.displayName(language: localization.language))
    }
}
```

### Current Language
```swift
localization.language // .english or .chinese
```

## Common Issues

### Build Failed - Database Locked
```bash
killall xcodebuild
rm -rf ~/Library/Developer/Xcode/DerivedData/WorkOutNow-*
xcodebuild clean -scheme WorkOutNow
```

### Missing App Icon Warnings
**Normal during development**
- Create `AppIcon-1024.png` (1024x1024, white barbell on black)
- Create `AppIcon-tinted.png` (monochrome version)
- Place in `Assets.xcassets/AppIcon.appiconset/`
- See `APP_ICON_INSTRUCTIONS.md` for details

### Sign in with Apple Not Working
**Simulator not supported** - Must use:
- Physical device with development profile
- TestFlight build
- App Store build

### iCloud Sync Not Working
1. Create CloudKit container in Apple Developer portal
2. Container ID: `iCloud.Christopher.WorkOutNow`
3. Enable iCloud in Xcode project capabilities
4. Test on physical devices with same Apple ID

## What Changed from Original

### Before
- ❌ Displayed BOTH languages simultaneously ("中文 English")
- ❌ Calendar showed red before plan creation (bug)
- ❌ No authentication or user profiles
- ❌ No iCloud sync
- ❌ 4 tabs only
- ❌ No settings

### After
- ✅ Shows ONLY selected language ("English" OR "中文")
- ✅ Calendar shows gray before plan creation
- ✅ Sign in with Apple authentication
- ✅ User profiles with body metrics tracking
- ✅ iCloud sync configured
- ✅ 5 tabs with Settings
- ✅ Language toggle in Settings

## Video Link Priority

### English Mode (Default)
1. **YouTube** (red) - appears first
2. **Bilibili** (cyan) - appears second

### Chinese Mode
1. **Bilibili** (cyan) - appears first
2. **YouTube** (red) - appears second

Both platforms accessible in both languages, only order changes.

## Data Models

### UserProfile
- Apple User ID (unique)
- Email, full name
- Birthday, gender
- Height (cm), weight (kg)

### BodyMetric
- Date, week start date
- Weight (kg)
- Body fat percentage
- Notes

## Next Steps

1. **Create App Icon** (manual task)
   - See `APP_ICON_INSTRUCTIONS.md`
   - Design: white barbell on black background
   - Size: 1024x1024 PNG

2. **Configure CloudKit**
   - Apple Developer portal
   - Create container: `iCloud.Christopher.WorkOutNow`
   - Enable for App ID

3. **Test on Device**
   - Build to physical device
   - Test Sign in with Apple
   - Test iCloud sync between 2 devices

4. **Write Tests**
   - CalendarColorCoder date logic
   - LocalizationManager language switching
   - Authentication flow

## Support

For detailed implementation information, see:
- `IMPLEMENTATION_SUMMARY.md` - Complete technical details
- `APP_ICON_INSTRUCTIONS.md` - Icon creation guide
- `CLAUDE.md` - Project overview and build commands

---

**Status**: ✅ BUILD SUCCESSFUL
**Language System**: ✅ WORKING
**Authentication**: ✅ CONFIGURED
**iCloud Sync**: ✅ READY
**Calendar Fix**: ✅ VERIFIED
**App Icon**: ⚠️ MANUAL SETUP NEEDED
