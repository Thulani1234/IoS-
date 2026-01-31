//
//  ContentView.swift
//  Thulani's_shop
//
//  Created by COBSCCOMP242P-028 on 2026-01-10.
//
import SwiftUI
import Combine

// MARK: - 🔹 ADDED: Player Manager
class PlayerManager: ObservableObject {
    @Published var playerName: String = ""
    @Published var isPlayerSet: Bool = false
}

// MARK: - Score History
struct ScoreRecord: Identifiable {
    let id = UUID()
    let player: String        // 🔹 ADDED: store player name
    let mode: String
    let score: Int
    let time: Int
    let date: Date
}

class ScoreManager: ObservableObject {
    @Published var history: [ScoreRecord] = []

    // 🔹 ADDED: include player name when saving score
    func add(player: String, mode: String, score: Int, time: Int) {
        history.insert(
            ScoreRecord(player: player, mode: mode, score: score, time: time, date: Date()),
            at: 0
        )
    }
}

// MARK: - MAIN APP
struct ContentView: View {
    @StateObject var scoreManager = ScoreManager()
    // 🔹 ADDED: player manager
    @StateObject var playerManager = PlayerManager()

    var body: some View {
        TabView {
            NavigationStack {
                // 🔹 ADDED: check if player is set
                if !playerManager.isPlayerSet {
                    PlayerEntryView(playerManager: playerManager)
                } else {
                    ZStack {
                        // 🎨 Main Menu Background
                        LinearGradient(
                            colors: [Color.purple.opacity(0.5), Color.blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()

                        VStack(spacing: 30) {
                            Spacer()
                            // 🔹 ADDED: Welcome message
                            Text("👋 Welcome, \(playerManager.playerName)")
                                .font(.title2.bold())
                                .foregroundColor(.white)

                            Text("🎨 Color Cube Matching Game")
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .shadow(radius: 5)

                            VStack(spacing: 18) {
                                NavigationLink("Easy") { EasyGameView(scoreManager: scoreManager, playerManager: playerManager) }
                                NavigationLink("Medium") { MediumGameView(scoreManager: scoreManager, playerManager: playerManager) }
                                NavigationLink("Hard") { HardGameView(scoreManager: scoreManager, playerManager: playerManager) }
                                NavigationLink("📘 How to Play") { InstructionsView() }

                                // 🔹 ADDED: Button to change player
                                Button("🔁 Change Player") {
                                    playerManager.isPlayerSet = false
                                    playerManager.playerName = ""
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
            .tabItem { Label("Play", systemImage: "gamecontroller") }

            NavigationStack { ScoreHistoryView(scoreManager: scoreManager) }
                .tabItem { Label("History", systemImage: "list.bullet.rectangle") }
        }
    }
}

// MARK: - 🔹 ADDED: Player Entry View
struct PlayerEntryView: View {
    @ObservedObject var playerManager: PlayerManager

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🎮 Enter Player Name")
                .font(.largeTitle.bold())
            TextField("Your Name", text: $playerManager.playerName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            Button("Start Game") {
                if !playerManager.playerName.isEmpty {
                    playerManager.isPlayerSet = true
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(playerManager.playerName.isEmpty)
            Spacer()
        }
        .padding()
    }
}

// MARK: - SCORE HISTORY VIEW
struct ScoreHistoryView: View {
    @ObservedObject var scoreManager: ScoreManager

    var body: some View {
        VStack {
            Text("🏆 Score History")
                .font(.largeTitle.bold())
                .padding()

            if scoreManager.history.isEmpty {
                Text("No scores yet. Play a game first!")
                    .font(.title3)
                    .foregroundColor(.gray)
            } else {
                List(scoreManager.history) { record in
                    VStack(alignment: .leading) {
                        // 🔹 ADDED: show player name
                        Text("👤 \(record.player)").font(.headline)
                        Text("\(record.mode) Mode - Score: \(record.score) - Time: \(record.time)s")
                        Text("Date: \(record.date.formatted(date: .numeric, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(4)
                }
            }
        }
    }
}

// MARK: - REUSABLE CARD VIEW
struct GameCardView: View {
    let color: Color
    let flipped: Bool
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(flipped ? color : .white)
            .shadow(radius: 3)
            .frame(height: height)
            .rotation3DEffect(
                .degrees(flipped ? 0 : 180),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.easeInOut(duration: 0.35), value: flipped)
    }
}

// MARK: - EASY GAME 3x3
struct EasyGameView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow]

    @State private var colorIndexes: [Int] = []
    @State private var revealed = Array(repeating: false, count: 9)
    @State private var matched = Array(repeating: false, count: 9)
    @State private var firstIndex: Int? = nil
    @State private var secondIndex: Int? = nil
    @State private var isBusy = false
    @State private var score = 0
    @State private var time = 0
    @State private var hintUsed = false
    @State private var showWin = false
    @State private var timer: Timer? = nil

    @ObservedObject var scoreManager: ScoreManager
    @ObservedObject var playerManager: PlayerManager // 🔹 ADDED

    var body: some View {
        GameView(
            title: "Easy Mode",
            grid: 3,
            totalCards: 9,
            pairCount: 4,
            scoreValue: 10,
            colors: colors,
            colorIndexes: $colorIndexes,
            revealed: $revealed,
            matched: $matched,
            firstIndex: $firstIndex,
            secondIndex: $secondIndex,
            busy: $isBusy,
            score: $score,
            time: $time,
            hintUsed: $hintUsed,
            timer: $timer,
            showWin: $showWin,
            scoreManager: scoreManager,
            playerManager: playerManager // 🔹 ADDED
        )
    }
}

// MARK: - MEDIUM GAME 5x5
struct MediumGameView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan, .mint, .indigo, .teal, .brown]

    @State private var colorIndexes: [Int] = []
    @State private var revealed = Array(repeating: false, count: 25)
    @State private var matched = Array(repeating: false, count: 25)
    @State private var firstIndex: Int? = nil
    @State private var secondIndex: Int? = nil
    @State private var isBusy = false
    @State private var score = 0
    @State private var time = 0
    @State private var hintUsed = false
    @State private var timer: Timer? = nil
    @State private var showWin = false

    @ObservedObject var scoreManager: ScoreManager
    @ObservedObject var playerManager: PlayerManager // 🔹 ADDED

    var body: some View {
        GameView(
            title: "Medium Mode",
            grid: 5,
            totalCards: 25,
            pairCount: 12,
            scoreValue: 15,
            colors: colors,
            colorIndexes: $colorIndexes,
            revealed: $revealed,
            matched: $matched,
            firstIndex: $firstIndex,
            secondIndex: $secondIndex,
            busy: $isBusy,
            score: $score,
            time: $time,
            hintUsed: $hintUsed,
            timer: $timer,
            showWin: $showWin,
            scoreManager: scoreManager,
            playerManager: playerManager // 🔹 ADDED
        )
    }
}

// MARK: - HARD GAME 7x7
struct HardGameView: View {
    let colors: [Color] = [
        .red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan, .mint, .indigo, .teal, .brown,
        .gray, .black, .red.opacity(0.7), .blue.opacity(0.7), .green.opacity(0.7), .yellow.opacity(0.7),
        .purple.opacity(0.7), .orange.opacity(0.7), .pink.opacity(0.7), .cyan.opacity(0.7),
        .mint.opacity(0.7), .indigo.opacity(0.7)
    ]

    @State private var colorIndexes: [Int] = []
    @State private var revealed = Array(repeating: false, count: 49)
    @State private var matched = Array(repeating: false, count: 49)
    @State private var firstIndex: Int? = nil
    @State private var secondIndex: Int? = nil
    @State private var isBusy = false
    @State private var score = 0
    @State private var time = 0
    @State private var hintUsed = false
    @State private var timer: Timer? = nil
    @State private var showWin = false

    @ObservedObject var scoreManager: ScoreManager
    @ObservedObject var playerManager: PlayerManager // 🔹 ADDED

    var body: some View {
        GameView(
            title: "Hard Mode",
            grid: 7,
            totalCards: 49,
            pairCount: 24,
            scoreValue: 20,
            colors: colors,
            colorIndexes: $colorIndexes,
            revealed: $revealed,
            matched: $matched,
            firstIndex: $firstIndex,
            secondIndex: $secondIndex,
            busy: $isBusy,
            score: $score,
            time: $time,
            hintUsed: $hintUsed,
            timer: $timer,
            showWin: $showWin,
            scoreManager: scoreManager,
            playerManager: playerManager // 🔹 ADDED
        )
    }
}

// MARK: - GENERIC GAME VIEW WITH WIN OVERLAY
struct GameView: View {
    let title: String
    let grid: Int
    let totalCards: Int
    let pairCount: Int
    let scoreValue: Int
    let colors: [Color]

    @Binding var colorIndexes: [Int]
    @Binding var revealed: [Bool]
    @Binding var matched: [Bool]
    @Binding var firstIndex: Int?
    @Binding var secondIndex: Int?
    @Binding var busy: Bool
    @Binding var score: Int
    @Binding var time: Int
    @Binding var hintUsed: Bool
    @Binding var timer: Timer?
    @Binding var showWin: Bool

    var scoreManager: ScoreManager
    var playerManager: PlayerManager // 🔹 ADDED

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text(title).font(.largeTitle.bold())
                Text("Score: \(score) • ⏱ \(time)s").foregroundColor(.secondary)
                Text(!showWin ? "Match the Colors" : "").font(.title3.weight(.semibold))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: grid), spacing: 10) {
                    ForEach(0..<totalCards, id: \.self) { i in
                        GameCardView(
                            color: cardColor(i),
                            flipped: revealed[i] || matched[i],
                            height: grid == 3 ? 90 : (grid == 5 ? 60 : 40)
                        )
                        .onTapGesture { tap(i) }
                    }
                }

                HStack(spacing: 16) {
                    Button("💡 Hint", action: hint).disabled(hintUsed)
                    Button("🔄 Restart", action: setup)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            if showWin {
                Color.black.opacity(0.6).ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("🎉 You Won!").font(.system(size: 36, weight: .bold)).foregroundColor(.white)
                    Text("Score: \(score)\nTime: \(time)s")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .font(.title2)
                    Button("🏁 Play Again") {
                        showWin = false
                        setup()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.purple))
                .shadow(radius: 8)
            }
        }
        .onAppear(perform: setup)
        .onDisappear { timer?.invalidate() }
    }

    func setup() {
        colorIndexes = Array(0..<pairCount).flatMap { [$0,$0] } + [pairCount]
        colorIndexes.shuffle()
        revealed = Array(repeating: false, count: colorIndexes.count)
        matched = Array(repeating: false, count: colorIndexes.count)
        if let free = colorIndexes.firstIndex(of: pairCount) { matched[free] = true }
        firstIndex = nil; secondIndex = nil; busy = false; score = 0; time = 0; hintUsed = false; showWin = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in time += 1 }
    }

    func cardColor(_ i: Int) -> Color {
        if matched[i] && colorIndexes[i] == pairCount { return .gray.opacity(0.3) }
        return (revealed[i] || matched[i]) ? colors[colorIndexes[i]] : .gray.opacity(0.4)
    }

    func tap(_ i: Int) {
        if busy || revealed[i] || matched[i] { return }
        revealed[i] = true
        if firstIndex == nil { firstIndex = i }
        else { secondIndex = i; check() }
    }

    func check() {
        busy = true
        if colorIndexes[firstIndex!] == colorIndexes[secondIndex!] {
            matched[firstIndex!] = true
            matched[secondIndex!] = true
            score += scoreValue
            if matched.allSatisfy({ $0 }) {
                timer?.invalidate()
                showWin = true
                // 🔹 ADDED: save player name with score
                scoreManager.add(player: playerManager.playerName, mode: title, score: score, time: time)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { reset() }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                revealed[firstIndex!] = false
                revealed[secondIndex!] = false
                reset()
            }
        }
    }

    func reset() { firstIndex = nil; secondIndex = nil; busy = false }

    func hint() {
        hintUsed = true
        for i in 0..<revealed.count where !matched[i] { revealed[i] = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            for i in 0..<revealed.count where !matched[i] { revealed[i] = false }
        }
    }
}

// MARK: - INSTRUCTIONS
struct InstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("🎨 Color Cube Memory Game")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
                Text("Challenge your memory, improve focus, and have fun matching colorful cubes! 🧠✨")
                    .font(.title3)
                    .foregroundColor(.secondary)
                SectionCard(title: "📝 How to Play", items: [
                    "Select a difficulty: Easy (3x3), Medium (5x5), or Hard (7x7).",
                    "Tap any cube to reveal its hidden color 🎨.",
                    "Tap a second cube to find its matching color 🔍.",
                    "If the colors match, they stay revealed ✅.",
                    "If they don't match, they flip back ❌.",
                    "Keep finding pairs until all cubes are matched 🏆."
                ])
                SectionCard(title: "💡 Hint Feature", items: [
                    "You can use the Hint button once per game.",
                    "All unmatched cubes will briefly flip to show their colors 👀.",
                    "Use hints strategically to improve your score and finish faster."
                ])
                SectionCard(title: "⭐ Scoring System", items: [
                    "Easy: +10 points per pair",
                    "Medium: +15 points per pair",
                    "Hard: +20 points per pair",
                    "No points are deducted for wrong matches ❌",
                    "Aim for the highest score possible!"
                ])
                SectionCard(title: "⏱️ Time Challenge", items: [
                    "Each game tracks your total time ⚡.",
                    "Finish faster to achieve better records.",
                    "Time is displayed at the top along with your current score."
                ])
                SectionCard(title: "📊 Score History", items: [
                    "After each game, your score and time are saved automatically.",
                    "Click the Score History tab at the bottom to view past scores.",
                    "Track your improvement and aim for the leaderboard! 🏅"
                ])
            }
            .padding()
        }
    }
}

struct SectionCard: View {
    let title: String
    let items: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title2.bold())
            ForEach(items, id: \.self) { item in
                Text("• \(item)")
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.purple.opacity(0.1)))
    }
}
