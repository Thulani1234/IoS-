//
//  ContentView.swift
//  Thulani's_shop
//
//  Created by COBSCCOMP242P-028 on 2026-01-10.
//
import SwiftUI

// MARK: - Main Menu
struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                Text("🎨 Color Cube Matching Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                VStack(spacing: 20) {
                    NavigationLink("Easy") {
                        EasyGameView()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    NavigationLink("Medium") {
                        MediumGameView()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    NavigationLink("Hard") {
                        HardGameView()
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
    }
}

// MARK: - Easy Game 3x3
// MARK: - Easy Game 3x3 WITH SCORE
// MARK: - Easy Game 4x4 WITH SCORE
struct EasyGameView: View {

    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan]

    @State private var colorIndexes: [Int] = []
    @State private var revealed = Array(repeating: false, count: 16)
    @State private var matched = Array(repeating: false, count: 16)

    @State private var firstIndex: Int? = nil
    @State private var secondIndex: Int? = nil
    @State private var isBusy = false
    @State private var statusText = "Match the Colors"

    @State private var score = 0

    var body: some View {
        VStack(spacing: 20) {

            Text("Score: \(score)")
                .font(.title3)
                .fontWeight(.bold)

            Text(statusText)
                .font(.title2)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(0..<16, id: \.self) { index in
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
    }

    func setupGame() {
        colorIndexes = Array(0..<8).flatMap { [$0,$0] } // 8 pairs
        colorIndexes.shuffle()

        revealed = Array(repeating: false, count: 16)
        matched = Array(repeating: false, count: 16)

        firstIndex = nil
        secondIndex = nil
        isBusy = false
        score = 0
        statusText = "Match the Colors"
    }

    func cardColor(_ index: Int) -> Color {
        (revealed[index] || matched[index]) ? colors[colorIndexes[index]] : .gray
    }

    func cardTapped(_ index: Int) {
        if isBusy || matched[index] { return }

        revealed[index] = true

        if firstIndex == nil {
            firstIndex = index
        } else {
            secondIndex = index
            checkMatch()
        }
    }

    func checkMatch() {
        isBusy = true

        if colorIndexes[firstIndex!] == colorIndexes[secondIndex!] {
            matched[firstIndex!] = true
            matched[secondIndex!] = true
            score += 10
            statusText = "Matched ✅ (+10)"

            let allMatched = matched.allSatisfy { $0 }
            if allMatched { statusText = "🎉 You Win! Score: \(score)" }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { resetSelection() }
        } else {
            score -= 2
            statusText = "Not Matched ❌ (-2)"

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                revealed[firstIndex!] = false
                revealed[secondIndex!] = false
                resetSelection()
            }
        }
    }

    func resetSelection() {
        firstIndex = nil
        secondIndex = nil
        isBusy = false
    }
}


// MARK: - Medium Game 5x5
// MARK: - Medium Game 5x5 WITH SCORE
// MARK: - Medium Game 6x6 WITH SCORE
struct MediumGameView: View {

    let colors: [Color] = [.red,.blue,.green,.yellow,.purple,.orange,.pink,.cyan,.mint,.indigo,.teal,.brown,.gray,.black,.white,.brown.opacity(0.7),.mint.opacity(0.7),.purple.opacity(0.7)]

    @State private var colorIndexes: [Int] = []
    @State private var revealed = Array(repeating: false, count: 36)
    @State private var matched = Array(repeating: false, count: 36)

    @State private var firstIndex: Int? = nil
    @State private var secondIndex: Int? = nil
    @State private var isBusy = false
    @State private var statusText = "Match the Colors"

    @State private var score = 0

    var body: some View {
        VStack(spacing: 20) {

            Text("Score: \(score)")
                .font(.title3)
                .fontWeight(.bold)

            Text(statusText)
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                ForEach(0..<36, id: \.self) { index in
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
    }

    func setupGame() {
        colorIndexes = Array(0..<18).flatMap { [$0,$0] } // 18 pairs
        colorIndexes.shuffle()

        revealed = Array(repeating: false, count: 36)
        matched = Array(repeating: false, count: 36)

        firstIndex = nil
        secondIndex = nil
        isBusy = false
        score = 0
        statusText = "Match the Colors"
    }

    func cardColor(_ index: Int) -> Color {
        (revealed[index] || matched[index]) ? colors[colorIndexes[index]] : .gray
    }

    func cardTapped(_ index: Int) {
        if isBusy || matched[index] { return }

        revealed[index] = true

        if firstIndex == nil {
            firstIndex = index
        } else {
            secondIndex = index
            checkMatch()
        }
    }

    func checkMatch() {
        isBusy = true

        if colorIndexes[firstIndex!] == colorIndexes[secondIndex!] {
            matched[firstIndex!] = true
            matched[secondIndex!] = true
            score += 15
            statusText = "Matched ✅ (+15)"

            let allMatched = matched.allSatisfy { $0 }
            if allMatched { statusText = "🎉 You Win! Score: \(score)" }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { resetSelection() }
        } else {
            score -= 3
            statusText = "Not Matched ❌ (-3)"

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                revealed[firstIndex!] = false
                revealed[secondIndex!] = false
                resetSelection()
            }
        }
    }

    func resetSelection() {
        firstIndex = nil
        secondIndex = nil
        isBusy = false
    }
}


// MARK: - Hard Mode
struct HardGameView: View {
    var body: some View {
        Text("Hard Mode Coming Soon 🔥")
            .font(.title)
            .fontWeight(.bold)
    }
}

// MARK: - Instructions Page
struct InstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("📘 Game Instructions")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                instructionRow("Tap a cube to reveal its color.")
                instructionRow("Tap another cube to find its matching pair.")
                instructionRow("If colors match, they stay visible.")
                instructionRow("If not, they flip back.")
                instructionRow("One cube is unique and cannot be matched.")

                Divider()

                Text("🏆 Objective")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Match all color pairs to win the game.")
            }
            .padding()
        }
    }

    func instructionRow(_ text: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
            Text(text)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 
