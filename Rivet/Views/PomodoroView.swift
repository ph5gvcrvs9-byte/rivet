//
//  PomodoroView.swift
//  Rivet
//
//  Created by yessa on 5/20/26.
//

import Combine
import SwiftData
import SwiftUI
import AVFoundation
import UserNotifications

struct PomodoroView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Streak.date, order: .forward) var streaks: [Streak]
    
    @State private var player: AVAudioPlayer?
    
    private let focusTimes: [Int] = [60 * 25, 60 * 5, 60 * 15]
    
    private let focusColors: [Color] = [
        Color.yellow, Color.blue, Color.green,
    ]
    
    private let focusTexts: [String] = [
        "Focus", "Short break", "Long break",
    ]
    
    private var focusNotificationTitles: [String] = [
        "It's time for a break!",
        "Your short break is up!",
        "Your long break is up! Time to lock in."
    ]
    
    private var focusNotificationBody: [String] = [
        "You finished another round, great work! Time for a break.",
        "It's time to lock in again.",
        "Down for another focus session?"
    ]
    
    // timerType: focus = 0, short break = 1, long break = 2
    @AppStorage("timerType") private var timerType: Int = 0
    @AppStorage("pomodoroGoal") private var pomodoroGoal: Int = 4
    
    @AppStorage("pomodoroCount") private var pomodoroCount: Int = 1
    @AppStorage("timeRemaining") private var timeRemaining: Int = 25 * 60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Binding var timerStart: Bool
    
    @Binding var streakCount: Int
    
    init(streakCount: Binding<Int>, timerStart: Binding<Bool>) {
        self._streakCount = streakCount
        self._timerStart = timerStart
    }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(focusTexts[timerType])
                    Spacer()
                    Text("\(pomodoroCount)/4")
                        .foregroundStyle(.gray)
                }
                .frame(width: 118)
                .font(
                    Font.custom(
                        "Jua-Regular",
                        size: 14
                    )
                )
                HStack {
                    ZStack {
                        let total = Double(focusTimes[timerType])
                        CircularProgressView(
                            progress: total > 0
                            ? Double(timeRemaining) / total : 0,
                            width: 50,
                            color: focusColors[timerType]
                        )
                        .frame(height: 70)
                        let minutes = timeRemaining / 60
                        let seconds = timeRemaining % 60
                        let secondsString = String(format: "%02d", seconds)
                        Text("\(minutes):\(secondsString)")
                            .font(
                                Font.custom(
                                    "Jua-Regular",
                                    size: 10
                                )
                            )
                            .foregroundStyle(focusColors[timerType])
                    }
                    VStack(spacing: 5) {
                        Button {
                            timerStart.toggle()
                            if timerStart == false {
                                cancelNotification(id: "timerDone")
                            } else {
                                scheduleNotification(
                                    id: "timerDone",
                                    in: TimeInterval(timeRemaining),
    //                                in: 25 * 60,
                                    title: focusNotificationTitles[timerType],
                                    body: focusNotificationBody[timerType]
                                )
                            }
                            
                        } label: {
                            Label(
                                "Start",
                                systemImage: timerStart
                                ? "pause.fill" : "play.fill"
                            )
                        }
                        .labelStyle(.iconOnly)
                        .font(
                            Font.custom(
                                "Jua-Regular",
                                size: 12
                            )
                        )
                        
                        if timerStart {
                            Button {
                                timerStart = false
                                timeRemaining = focusTimes[timerType]
                                cancelNotification(id: "timerDone")
                                
                            } label: {
                                Label("Start", systemImage: "stop.fill")
                            }
                            .labelStyle(.iconOnly)
                            .font(
                                Font.custom(
                                    "Jua-Regular",
                                    size: 12
                                )
                            )
                        }
                        
                    }
                    
                }
                VStack(alignment: .leading, spacing: -2) {
                    HStack {
                        Text("today's pomodoro:")
                            .font(
                                Font.custom(
                                    "Jua-Regular",
                                    size: 10
                                )
                            )
                            .foregroundStyle(.gray)
                            .frame(width: 85)
                        Spacer()
                        Text("\((streaks.last?.pomodoroCount) ?? 0)/\(pomodoroGoal)", )
                            .font(
                                Font.custom(
                                    "Jua-Regular",
                                    size: 10
                                )
                            )
                            .foregroundStyle(.orange)
                    }
                    
                }
                .padding(.top, 5)
                
                //                List{
                //                    ForEach(streaks) {streak in
                //                        Text(streak.date, style: .date)
                //                        Text(String(streak.pomodoroCount))
                //                    }
                //                }
            }
            .padding(5)
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 && timerStart {
                timeRemaining -= 1
            }
            if timeRemaining == 0 && timerStart {
                timerStart = false
                if timerType == 0 {
                    if pomodoroCount < 4 {
                        timerType = 1
                        pomodoroCount += 1
                    } else {
                        timerType = 2
                        pomodoroCount = 1
                    }
                    addPomodoroCount()
                    countStreak()
                } else {
                    timerType = 0
                }
                timeRemaining = focusTimes[timerType]
            }
        }
        .onChange(of: timerType) { _, newValue in
            timeRemaining = focusTimes[newValue]
        }
        .onAppear {
            
            //                         resetStreaks() // Uncomment to clear all Streak records on appear
            countStreak()
            if timeRemaining <= 0 {
                timeRemaining = focusTimes[timerType]
            }
            addRecord()
            print(streaks)
        }
    }
    
    func addRecord() {
        let today = Calendar.current.startOfDay(for: Date())
        
        let mostRecent =
        streaks
            .map { Calendar.current.startOfDay(for: $0.date) }
            .max() ?? Calendar.current.date(
                byAdding: .day,
                value: -1,
                to: today
            )!
        
        var cursor = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: mostRecent
        )!
        
        while cursor <= today {
            let newRecord = Streak(date: cursor)
            modelContext.insert(newRecord)
            cursor = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: cursor
            )!
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save streaks: \(error)")
        }
    }
    
    func addPomodoroCount() {
        if let streak = streaks.last {
            streak.pomodoroCount += 1
            try? modelContext.save()
        }
    }
    
    func resetStreaks() {
        do {
            try modelContext.delete(model: Streak.self)
            try modelContext.save()
        } catch {
            print("Failed to reset data: \(error)")
        }
    }
    
    func countStreak() {
        streakCount = 0
        for streak in streaks.reversed() {
            print(streak.date)
            print(streak.pomodoroCount)
            if streak.pomodoroCount > 0 {
                
                streakCount += 1
            } else {
                return
            }
        }
        
    }
    func playSound() {
        guard let soundURL = Bundle.main.url(forResource: "Ringtone1", withExtension: "caf") else {
          return
        }

        do {
          player = try AVAudioPlayer(contentsOf: soundURL)
        } catch {
          print("Failed to load the sound: \(error)")
        }
        player?.play()
      }
    
    func scheduleNotification(id: String, in seconds: TimeInterval, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound(named: UNNotificationSoundName("Ringtone1.caf"))

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule: \(error)")
            }
        }
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}

#Preview {
    PomodoroView(streakCount: .constant(0), timerStart: .constant(false))
        .padding()
}
