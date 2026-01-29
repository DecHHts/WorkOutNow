//
//  ExerciseSeeder.swift
//  WorkOutNow
//
//  Created by Claude on 2026/01/29.
//

import Foundation
import SwiftData

class ExerciseSeeder {
    static func seedExercises(modelContext: ModelContext) {
        // Chest exercises (5)
        let chestExercises = [
            Exercise(
                nameEnglish: "Barbell Bench Press",
                nameChinese: "杠铃卧推",
                muscleGroup: .chest,
                videoURLYouTube: "rT7DgCr-3pg",
                videoURLBilibili: "BV1xx411c7SZ"
            ),
            Exercise(
                nameEnglish: "Dumbbell Flyes",
                nameChinese: "哑铃飞鸟",
                muscleGroup: .chest,
                videoURLYouTube: "eozdVDA78K0",
                videoURLBilibili: "BV1yW411q7Ls"
            ),
            Exercise(
                nameEnglish: "Push-ups",
                nameChinese: "俯卧撑",
                muscleGroup: .chest,
                videoURLYouTube: "IODxDxX7oi4",
                videoURLBilibili: "BV1Ws411e7vJ"
            ),
            Exercise(
                nameEnglish: "Incline Dumbbell Press",
                nameChinese: "上斜哑铃卧推",
                muscleGroup: .chest,
                videoURLYouTube: "8iPEnn-ltC8",
                videoURLBilibili: "BV1Es411e7Mk"
            ),
            Exercise(
                nameEnglish: "Cable Crossover",
                nameChinese: "绳索夹胸",
                muscleGroup: .chest,
                videoURLYouTube: "taI4XduLpTk",
                videoURLBilibili: "BV1Hs411e7sK"
            )
        ]

        // Back exercises (5)
        let backExercises = [
            Exercise(
                nameEnglish: "Deadlift",
                nameChinese: "硬拉",
                muscleGroup: .back,
                videoURLYouTube: "op9kVnSso6Q",
                videoURLBilibili: "BV1Ws411e7eB"
            ),
            Exercise(
                nameEnglish: "Pull-ups",
                nameChinese: "引体向上",
                muscleGroup: .back,
                videoURLYouTube: "eGo4IYlbE5g",
                videoURLBilibili: "BV1Hs411e7cM"
            ),
            Exercise(
                nameEnglish: "Barbell Row",
                nameChinese: "杠铃划船",
                muscleGroup: .back,
                videoURLYouTube: "FWJR5Ve8bnQ",
                videoURLBilibili: "BV1Es411e7dP"
            ),
            Exercise(
                nameEnglish: "Lat Pulldown",
                nameChinese: "高位下拉",
                muscleGroup: .back,
                videoURLYouTube: "CAwf7n6Luuc",
                videoURLBilibili: "BV1Ws411e7fQ"
            ),
            Exercise(
                nameEnglish: "Seated Cable Row",
                nameChinese: "坐姿划船",
                muscleGroup: .back,
                videoURLYouTube: "xQNrFHEMhI4",
                videoURLBilibili: "BV1Hs411e7gR"
            )
        ]

        // Shoulder exercises (4)
        let shoulderExercises = [
            Exercise(
                nameEnglish: "Overhead Press",
                nameChinese: "肩推",
                muscleGroup: .shoulders,
                videoURLYouTube: "QAQ64hK4Xns",
                videoURLBilibili: "BV1Es411e7hS"
            ),
            Exercise(
                nameEnglish: "Lateral Raises",
                nameChinese: "侧平举",
                muscleGroup: .shoulders,
                videoURLYouTube: "3VcKaXpzqRo",
                videoURLBilibili: "BV1Ws411e7iT"
            ),
            Exercise(
                nameEnglish: "Front Raises",
                nameChinese: "前平举",
                muscleGroup: .shoulders,
                videoURLYouTube: "SVT4-H2aXjg",
                videoURLBilibili: "BV1Hs411e7jU"
            ),
            Exercise(
                nameEnglish: "Face Pulls",
                nameChinese: "面拉",
                muscleGroup: .shoulders,
                videoURLYouTube: "rep-qVOkqgk",
                videoURLBilibili: "BV1Es411e7kV"
            )
        ]

        // Biceps exercises (3)
        let bicepsExercises = [
            Exercise(
                nameEnglish: "Barbell Curl",
                nameChinese: "杠铃弯举",
                muscleGroup: .biceps,
                videoURLYouTube: "kwG2ipFRgfo",
                videoURLBilibili: "BV1Ws411e7lW"
            ),
            Exercise(
                nameEnglish: "Hammer Curl",
                nameChinese: "锤式弯举",
                muscleGroup: .biceps,
                videoURLYouTube: "zC3nLlEvin4",
                videoURLBilibili: "BV1Hs411e7mX"
            ),
            Exercise(
                nameEnglish: "Preacher Curl",
                nameChinese: "牧师凳弯举",
                muscleGroup: .biceps,
                videoURLYouTube: "fIWP-FRFNU0",
                videoURLBilibili: "BV1Es411e7nY"
            )
        ]

        // Triceps exercises (3)
        let tricepsExercises = [
            Exercise(
                nameEnglish: "Tricep Dips",
                nameChinese: "双杠臂屈伸",
                muscleGroup: .triceps,
                videoURLYouTube: "6kALZikXxLc",
                videoURLBilibili: "BV1Ws411e7oZ"
            ),
            Exercise(
                nameEnglish: "Overhead Tricep Extension",
                nameChinese: "过头臂屈伸",
                muscleGroup: .triceps,
                videoURLYouTube: "YbX7Wd8jQ-Q",
                videoURLBilibili: "BV1Hs411e7p1"
            ),
            Exercise(
                nameEnglish: "Tricep Pushdown",
                nameChinese: "绳索下压",
                muscleGroup: .triceps,
                videoURLYouTube: "2-LAMcpzODU",
                videoURLBilibili: "BV1Es411e7q2"
            )
        ]

        // Leg exercises (6)
        let legExercises = [
            Exercise(
                nameEnglish: "Barbell Squat",
                nameChinese: "杠铃深蹲",
                muscleGroup: .legs,
                videoURLYouTube: "ultWZbUMPL8",
                videoURLBilibili: "BV1Ws411e7r3"
            ),
            Exercise(
                nameEnglish: "Leg Press",
                nameChinese: "腿举",
                muscleGroup: .legs,
                videoURLYouTube: "IZxyjW7MPJQ",
                videoURLBilibili: "BV1Hs411e7s4"
            ),
            Exercise(
                nameEnglish: "Walking Lunges",
                nameChinese: "行走弓步",
                muscleGroup: .legs,
                videoURLYouTube: "L8fvypPrzzs",
                videoURLBilibili: "BV1Es411e7t5"
            ),
            Exercise(
                nameEnglish: "Leg Curl",
                nameChinese: "腿弯举",
                muscleGroup: .legs,
                videoURLYouTube: "ELOCsoDSmrg",
                videoURLBilibili: "BV1Ws411e7u6"
            ),
            Exercise(
                nameEnglish: "Leg Extension",
                nameChinese: "腿屈伸",
                muscleGroup: .legs,
                videoURLYouTube: "YyvSfVjQeL0",
                videoURLBilibili: "BV1Hs411e7v7"
            ),
            Exercise(
                nameEnglish: "Calf Raises",
                nameChinese: "提踵",
                muscleGroup: .legs,
                videoURLYouTube: "gwLzBJYoWlI",
                videoURLBilibili: "BV1Es411e7w8"
            )
        ]

        // Core exercises (4)
        let coreExercises = [
            Exercise(
                nameEnglish: "Plank",
                nameChinese: "平板支撑",
                muscleGroup: .core,
                videoURLYouTube: "ASdvN_XEl_c",
                videoURLBilibili: "BV1Ws411e7x9"
            ),
            Exercise(
                nameEnglish: "Crunches",
                nameChinese: "卷腹",
                muscleGroup: .core,
                videoURLYouTube: "Xyd_fa5zoEU",
                videoURLBilibili: "BV1Hs411e7y0"
            ),
            Exercise(
                nameEnglish: "Russian Twist",
                nameChinese: "俄罗斯转体",
                muscleGroup: .core,
                videoURLYouTube: "wkD8rjkodUI",
                videoURLBilibili: "BV1Es411e7z1"
            ),
            Exercise(
                nameEnglish: "Hanging Leg Raises",
                nameChinese: "悬垂举腿",
                muscleGroup: .core,
                videoURLYouTube: "Pr1ieGZ5atk",
                videoURLBilibili: "BV1Ws411e7A2"
            )
        ]

        // Insert all exercises
        let allExercises = chestExercises + backExercises + shoulderExercises + bicepsExercises + tricepsExercises + legExercises + coreExercises

        for exercise in allExercises {
            modelContext.insert(exercise)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to seed exercises: \(error)")
        }
    }
}
