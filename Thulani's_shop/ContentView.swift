//
//  ContentView.swift
//  Thulani's_shop
//
//  Created by COBSCCOMP242P-028 on 2026-01-10.
//
import SwiftUI
import Combine

// MARK: - Score History
struct ScoreRecord: Identifiable {
    let id = UUID()
    let mode: String
    let score: Int
    let time: Int // seconds
    let date: Date
}

class ScoreManager: ObservableObject {
    @Published var history: [ScoreRecord] = []
    
    func add(mode: String, score: Int, time: Int) {
        history.insert(
            ScoreRecord(mode: mode, score: score, time: time, date: Date()),
            at: 0
        )
    }
}

// MARK: - Main Menu with TabView
struct ContentView: View {
    @StateObject var scoreManager = ScoreManager()
    
    var body: some View {
        TabView {
            NavigationStack {
                VStack(spacing: 40) {
                    Spacer()
                    Text("🎨 Color Cube Matching Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 20) {
                        NavigationLink("Easy") {
                            EasyGameView(scoreManager: scoreManager)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        NavigationLink("Medium") {
                            MediumGameView(scoreManager: scoreManager)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        NavigationLink("Hard") {
                            HardGameView(scoreManager: scoreManager)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        NavigationLink("📘 How to Play") {
                            InstructionsView()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    Spacer()
                }
                .padding()
            }
            .tabItem {
                Label("Play", systemImage: "gamecontroller")
            }
            
            NavigationStack {
                ScoreHistoryView(scoreManager: scoreManager)
            }
            .tabItem {
                Label("History", systemImage: "list.bullet.rectangle")
            }
        }
    }
}

// MARK: - Score History View
struct ScoreHistoryView: View {
    @ObservedObject var scoreManager: ScoreManager
    
    var body: some View {
        VStack {
            Text("🏆 Score History")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            if scoreManager.history.isEmpty {
                Text("No scores yet. Play a game first!")
                    .font(.title3)
                    .foregroundColor(.gray)
            } else {
                List(scoreManager.history) { record in
                    VStack(alignment: .leading) {
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

// MARK: - Easy Game 2x2
struct EasyGameView: View {
    let colors: [Color] = [.red, .blue]
    @State private var colorIndexes: [Int] = []
    @State private var revealed = Array(repeating: false, count: 4)
    @State private var matched = Array(repeating: false, count: 4)
    @State private var firstIndex: Int? = nil
    @State private var secondIndex: Int? = nil
    @State private var isBusy = false
    @State private var statusText = "Match the Colors"
    @State private var score = 0
    
    @State private var time = 0
    @State private var timer: Timer? = nil
    
    @ObservedObject var scoreManager: ScoreManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Score: \(score)").font(.title3).fontWeight(.bold)
            Text("Time: \(time)s").font(.headline)
            Text(statusText).font(.title2).fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                ForEach(0..<4, id: \.self) { index in
                    Rectangle()
                        .fill(cardColor(index))
                        .frame(height: 80)
                        .cornerRadius(10)
                        .onTapGesture { cardTapped(index) }
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black))
                }
            }
            
            Button("Restart Game") { setupGame() }
        }
        .padding()
        .onAppear { setupGame() }
        .onDisappear { timer?.invalidate() }
    }
    
    func setupGame() {
        colorIndexes = Array(0..<2).flatMap { [$0,$0] }
        colorIndexes.shuffle()
        revealed = Array(repeating: false, count: 4)
        matched = Array(repeating: false, count: 4)
        firstIndex = nil
        secondIndex = nil
        isBusy = false
        score = 0
        statusText = "Match the Colors"
        time = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            time += 1
        }
    }
    
    func cardColor(_ index: Int) -> Color {
        (revealed[index] || matched[index]) ? colors[colorIndexes[index]] : .gray
    }
    
    func cardTapped(_ index: Int) {
        if isBusy || matched[index] { return }
        revealed[index] = true
        
        if firstIndex == nil { firstIndex = index }
        else { secondIndex = index; checkMatch() }
    }
    
    func checkMatch() {
        isBusy = true
        if colorIndexes[firstIndex!] == colorIndexes[secondIndex!] {
            matched[firstIndex!] = true
            matched[secondIndex!] = true
            score += 10
            statusText = "Matched ✅ (+10)"
            
            if matched.allSatisfy({ $0 }) {
                statusText = "🎉 You Win! Score: \(score)"
                timer?.invalidate()
                scoreManager.add(mode: "Easy", score: score, time: time)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { resetSelection() }
        } else {
            statusText = "Not Matched ❌"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                revealed[firstIndex!] = false
                revealed[secondIndex!] = false
                resetSelection()
            }
        }
    }
    
    func resetSelection() { firstIndex = nil; secondIndex = nil; isBusy = false }
}

// MARK: - Medium Game 4x4
struct MediumGameView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan]
    
    @State private var colorIndexes: [Int] = []
    @State private var revealed = Array(repeating: false, count: 16)
    @State private var matched = Array(repeating: false, count: 16)
    @State private var firstIndex: Int? = nil
    @State private var secondIndex: Int? = nil
    @State private var isBusy = false
    @State private var statusText = "Match the Colors"
    @State private var score = 0
    
    @State private var time = 0
    @State private var timer: Timer? = nil
    
    @ObservedObject var scoreManager: ScoreManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Score: \(score)").font(.title3).fontWeight(.bold)
            Text("Time: \(time)s").font(.headline)
            Text(statusText).font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(0..<16, id: \.self) { index in
                    Rectangle()
                        .fill(cardColor(index))
                        .frame(height: 60)
                        .cornerRadius(10)
                        .onTapGesture { cardTapped(index) }
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black))
                }
            }
            
            Button("Restart Game") { setupGame() }
        }
        .padding()
        .onAppear { setupGame() }
        .onDisappear { timer?.invalidate() }
    }
    
    func setupGame() {
        colorIndexes = Array(0..<8).flatMap { [$0,$0] }
        colorIndexes.shuffle()
        revealed = Array(repeating: false, count: 16)
        matched = Array(repeating: false, count: 16)
        firstIndex = nil
        secondIndex = nil
        isBusy = false
        score = 0
        statusText = "Match the Colors"
        time = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            time += 1
        }
    }
    
    func cardColor(_ index: Int) -> Color {
        (revealed[index] || matched[index]) ? colors[colorIndexes[index]] : .gray
    }
    
    func cardTapped(_ index: Int) {
        if isBusy || matched[index] { return }
        revealed[index] = true
        if firstIndex == nil { firstIndex = index }
        else { secondIndex = index; checkMatch() }
    }
    
    func checkMatch() {
        isBusy = true
        if colorIndexes[firstIndex!] == colorIndexes[secondIndex!] {
            matched[firstIndex!] = true
            matched[secondIndex!] = true
            score += 15
            statusText = "Matched ✅ (+15)"
            
            if matched.allSatisfy({ $0 }) {
                statusText = "🎉 Medium Mode Cleared! Score: \(score)"
                timer?.invalidate()
                scoreManager.add(mode: "Medium", score: score, time: time)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { resetSelection() }
        } else {
            statusText = "Not Matched ❌"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                revealed[firstIndex!] = false
                revealed[secondIndex!] = false
                resetSelection()
            }
        }
    }
    
    func resetSelection() { firstIndex = nil; secondIndex = nil; isBusy = false }
}

// MARK: - Hard Game 6x6
struct HardGameView: View {
    let colors: [Color] = [
        .red, .blue, .green, .yellow, .purple, .orange,
        .pink, .cyan, .mint, .indigo, .teal, .brown,
        .gray, .black, .red.opacity(0.7), .blue.opacity(0.7),
        .green.opacity(0.7), .yellow.opacity(0.7)
    ]
    
    @State private var colorIndexes: [Int] = []
    @State private var revealed = Array(repeating: false, count: 36)
    @State private var matched = Array(repeating: false, count: 36)
    @State private var firstIndex: Int? = nil
    @State private var secondIndex: Int? = nil
    @State private var isBusy = false
    @State private var statusText = "Match the Colors"
    @State private var score = 0
    
    @State private var time = 0
    @State private var timer: Timer? = nil
    
    @ObservedObject var scoreManager: ScoreManager
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Score: \(score)").font(.title3).fontWeight(.bold)
            Text("Time: \(time)s").font(.headline)
            Text(statusText).font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                ForEach(0..<36, id: \.self) { index in
                    Rectangle()
                        .fill(cardColor(index))
                        .frame(height: 40)
                        .cornerRadius(6)
                        .onTapGesture { cardTapped(index) }
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 0.8))
                }
            }
            
            Button("Restart Game") { setupGame() }
        }
        .padding()
        .onAppear { setupGame() }
        .onDisappear { timer?.invalidate() }
    }
    
    func setupGame() {
        colorIndexes = Array(0..<18).flatMap { [$0,$0] }
        colorIndexes.shuffle()
        revealed = Array(repeating: false, count: 36)
        matched = Array(repeating: false, count: 36)
        firstIndex = nil
        secondIndex = nil
        isBusy = false
        score = 0
        statusText = "Match the Colors"
        time = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            time += 1
        }
    }
    
    func cardColor(_ index: Int) -> Color {
        (revealed[index] || matched[index]) ? colors[colorIndexes[index]] : .gray
    }
    
    func cardTapped(_ index: Int) {
        if isBusy || matched[index] || revealed[index] { return }
        revealed[index] = true
        if firstIndex == nil { firstIndex = index }
        else { secondIndex = index; checkMatch() }
    }
    
    func checkMatch() {
        isBusy = true
        if colorIndexes[firstIndex!] == colorIndexes[secondIndex!] {
            matched[firstIndex!] = true
            matched[secondIndex!] = true
            score += 20
            statusText = "Matched ✅ (+20)"
            
            if matched.allSatisfy({ $0 }) {
                statusText = "🔥 HARD MODE CLEARED! Score: \(score)"
                timer?.invalidate()
                scoreManager.add(mode: "Hard", score: score, time: time)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { resetSelection() }
        } else {
            statusText = "Not Matched ❌"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                revealed[firstIndex!] = false
                revealed[secondIndex!] = false
                resetSelection()
            }
        }
    }
    
    func resetSelection() { firstIndex = nil; secondIndex = nil; isBusy = false }
}

// MARK: - Instructions Page
// MARK: - Creative Instructions Page
struct InstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                
                // 🎨 Title
                Text("🎮 Color Cube Memory Game")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
                
                Text("Sharpen your memory and have fun! 🧠✨")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                // 📝 How to Play Section
                SectionCard(title: "📝 How to Play", items: [
                    "Tap a cube to reveal its hidden color 🎨",
                    "Tap a second cube to find its matching color 🔍",
                    "If both colors match, they stay open ✅",
                    "If they don’t match, they flip back ❌",
                    "Complete all pairs to clear the level 🏆"
                ])
                
                // ⭐ Scoring System Section
                SectionCard(title: "⭐ Scoring System", items: [
                    "Each correct match gives points ➕",
                    "Higher difficulty = more points 🔥",
                    "No points are deducted for wrong matches ❌",
                    "Aim for the highest score possible 🏅"
                ])
                
                // ⏱️ Time Challenge Section
                SectionCard(title: "⏱️ Time Challenge", items: [
                    "Complete levels faster for personal records ⚡",
                    "Track your time in the History tab 📊",
                    "Challenge your friends and beat their scores 🎯"
                ])
                
                // 🏆 Goal Section
                SectionCard(title: "🏆 Goal", items: [
                    "Match all the color pairs in each level",
                    "Improve memory, focus, and reflexes 🧠💡",
                    "Unlock higher levels for bigger challenges 🧩"
                ])
                
                Spacer()
            }
            .padding()
        }
        .background(LinearGradient(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.05)], startPoint: .top, endPoint: .bottom))
    }
}

// MARK: - Section Card View
struct SectionCard: View {
    var title: String
    var items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.blue)
                        .padding(.top, 6)
                    Text(item)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
