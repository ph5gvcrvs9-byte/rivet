//
//  ContentView.swift
//  Rivet
//
//  Created by yessa on 5/20/26.
//

import SwiftData
import SwiftUI
import UserNotifications

struct ContentView: View {
    @State var streakCount = 0
    
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                Text("Rivet")
                    .font(
                        Font.custom(
                            "Jua-Regular",
                            size: 16
                        )
                    )
                    .padding(.leading, 5)
                Spacer()
                GroupBox {
                    HStack(spacing: 5) {
                        Image(systemName: "flame.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10)
                            .foregroundStyle(streakCount > 0 ? .orange : .gray)
                            .animation(
                                .easeInOut(duration: 0.3),
                                value: streakCount
                            )

                        Text("\(String(streakCount))d")
                            .font(
                                Font.custom(
                                    "Jua-Regular",
                                    size: 12
                                )
                            )
                            .foregroundStyle(streakCount > 0 ? .orange : .gray)
                            .animation(
                                .easeInOut(duration: 0.3),
                                value: streakCount
                            )
                    }
                    .padding(.horizontal, 5)
                }

                Button {
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: [.alert, .badge, .sound]) { success, error in
                            if success {
                                print("All set!")
                            } else if let error {
                                print(error.localizedDescription)
                            }
                        }
                } label: {
                    Image(systemName: "gearshape.fill")
                }

            }

            HStack {

                PetView()
                PomodoroView(streakCount: $streakCount)
            }
        }
        .padding(10)
        .frame(width: 260)
        
    }
    
    func breakNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Lock in time!!"
        content.body = "Your break is done, it's time to lock in again."
        content.sound = UNNotificationSound(
            named: UNNotificationSoundName("Ringtone1.caf")
        )

        // Use a 1-second delay to fire immediately
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 0.1,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "ValueZeroAlarm",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
    
    func focusNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time for a break."
        content.body = "You just finished another pomodoro, great work! Now you should take a break."
        content.sound = UNNotificationSound(
            named: UNNotificationSoundName("Ringtone1.caf")
        )

        // Use a 1-second delay to fire immediately
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 0.1,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "ValueZeroAlarm",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Streak.self, inMemory: true)
}
