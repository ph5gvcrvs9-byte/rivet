//
//  PetView.swift
//  Rivet
//
//  Created by yessa on 5/20/26.
//

import SwiftUI
import SwiftData

struct PetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Streak.date, order: .forward) var streaks: [Streak]
    
    @AppStorage("name") private var name: String = "scottie"
    @State private var editingName: Bool = false
    @State private var isTapping = false
    
    @AppStorage("timerType") private var timerType: Int = 0
    @AppStorage("pomodoroGoal") private var pomodoroGoal: Int = 4
    
    @Binding var timerStart: Bool
    
    private var pomodoroCountToday: Int? {
        streaks.last?.pomodoroCount
    }
    
    
    private static let neutral: [String: Any] = [
        "name": "neutral",
        "image": "CatNeutralImage",
        "focus": true,
        "break": false,
        "idle": true,
        "type": "neutral",
        "color": Color.green
    ]

    private static let sleeping: [String: Any] = [
        "name": "sleeping",
        "image": "CatSleepingImage",
        "focus": false,
        "break": true,
        "idle": true,
        "type": "neutral",
        "color": Color.green
    ]

    private static let serious: [String: Any] = [
        "name": "serious",
        "image": "CatSeriousImage",
        "focus": true,
        "break": false,
        "idle": false,
        "type": "neutral",
        "color": Color.green
    ]
    
    private static let angry: [String: Any] = [
        "name": "angry",
        "image": "CatAngryImage",
        "focus": true,
        "break": false,
        "idle": false,
        "type": "25%",
        "color": Color.red
    ]

    private static let pleading: [String: Any] = [
        "name": "pleading",
        "image": "CatPleadingImage",
        "focus": false,
        "break": false,
        "idle": true,
        "type": "50%",
        "color": Color.blue
    ]

    private static let crying: [String: Any] = [
        "name": "crying",
        "image": "CatCryingImage",
        "focus": true,
        "break": false,
        "idle": true,
        "type": "50%",
        "color": Color.blue
    ]

    private static let sad: [String: Any] = [
        "name": "sad",
        "image": "CatSadImage",
        "focus": true,
        "break": false,
        "idle": true,
        "type": "50%",
        "color": Color.blue
    ]

    private static let dizzy: [String: Any] = [
        "name": "dizzy",
        "image": "CatDizzyImage",
        "focus": true,
        "break": true,
        "idle": false,
        "type": "50%",
        "color": Color.blue
    ]

    private static let happy1: [String: Any] = [
        "name": "happy",
        "image": "CatHappy1Image",
        "focus": true,
        "break": true,
        "idle": true,
        "type": "75%",
        "color": Color.yellow
    ]

    private static let happy2: [String: Any] = [
        "name": "happy",
        "image": "CatHappy2Image",
        "focus": true,
        "break": true,
        "idle": true,
        "type": "75%",
        "color": Color.yellow
    ]

    private static let happy3: [String: Any] = [
        "name": "very happy",
        "image": "CatHappy3Image",
        "focus": true,
        "break": true,
        "idle": true,
        "type": "100%",
        "color": Color.yellow
    ]

    private static let excited: [String: Any] = [
        "name": "ecstatic",
        "image": "CatExcitedImage",
        "focus": true,
        "break": true,
        "idle": true,
        "type": "100%",
        "color": Color.yellow
    ]
    
    
    private var emotion_dict: [String: [[String: Any]]] {
        [
            "neutral": [
                Self.neutral,
                Self.sleeping,
                Self.serious
            ],
            "25%": [
                Self.angry
            ],
            "50%": [
                Self.pleading,
                Self.crying,
                Self.sad,
                Self.dizzy
            ],
            "75%": [
                Self.happy1,
                Self.happy2
            ],
            "100%": [
                Self.happy3,
                Self.excited
            ]
        ]
    }
    
    
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                
                VStack(alignment: .center) {
                    if editingName {
                        HStack(spacing: 5) {
                            TextField("scottie", text: $name)
                                .font(
                                    Font.custom(
                                        "Jua-Regular",
                                        size: 16
                                    )
                                )
                                .frame(maxWidth: 100)

                                .fixedSize()
                                .onSubmit { editingName = false }
                                .padding(.bottom, 5)

                            Button {
                                withAnimation { editingName = false }
                            } label: {
                                Image(systemName: "checkmark")
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(height: 20)
                    } else {
                        HStack(spacing: 5) {
                            Text(name)
                                .font(
                                    Font.custom(
                                        "Jua-Regular",
                                        size: 16
                                    )
                                )
                            Button {
                                withAnimation { editingName = true }
                            } label: {
                                Image(systemName: "pencil")
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(height: 20)
                    }

                    Text(determineEmotion()?["name"] as? String ?? "CatNeutralImage")
                        .font(
                            Font.custom(
                                "Jua-Regular",
                                size: 10
                            )
                        )
                        .foregroundStyle(.yellow)

                    Image(determineEmotion()?["image"] as? String ?? "CatNeutralImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80)
                        .padding(.top, 5)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    isTapping = true
                                }
                                .onEnded { _ in
                                    isTapping = false
                                }
                        )
                        .scaleEffect(isTapping ? 2.0 : 1.7)
                        .animation(.bouncy, value: isTapping)
                }

            }
            .padding(5)
            .frame(height: 110)
        }

    }
    
    func determinePercentage() -> String{
        let percent: Double = Double(pomodoroCountToday ?? 0) / Double(pomodoroGoal)
        print(percent)
        if percent >= 1.0 {
            return "100%"
        } else if percent >= 0.50 {
            return "75%"
        } else if percent >= 0.25 {
            return "50%"
        } else if percent >= 0 {
            return "25%"
        } else {
            return "neutral"
        }
        
        
    }
    
    func randomEmotion() -> [String: Any]? {
        return emotion_dict[determinePercentage()]?.randomElement()
    }
    
    func determineEmotion() -> [String: Any]?{
        if timerType == 0 && timerStart {
            return PetView.serious
        } else if timerType == 1 && timerStart {
            return PetView.sleeping
        } else if timerType == 2 && timerStart {
            return PetView.dizzy
        } else {
            return randomEmotion()
        }
    }
}

#Preview {
    PetView(timerStart: .constant(false))
        .padding(10)
}

