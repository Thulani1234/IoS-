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
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Easy Game 3x3 (Original Code)
struct EasyGameView: View {

    let colors: [Color] = [.red, .blue, .green, .yellow, .purple]
    let colorNames: [String] = ["Red", "Blue", "Green", "Yellow", "Purple"]

    @State private var colorIndexes: [Int] = []
    @State private var revealed: [Bool] = Array(repeating: false, count: 9)
    @State private var matched: [Bool] = Array(repeating: false, count: 9)

    @State private var firstIndex: Int? = nil
    @State private var secondIndex: Int? = nil
    @State private var isBusy = false
    @State private var statusText = "Match the Colors"

    var body: some View {
        VStack(spacing: 20) {

            Text(statusText)
                .font(.title2)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(0..<9, id: \.self) { index in
                    Rectangle()
                        .fill(cardColor(index))
                        .frame(height: 90)
                        .cornerRadius(10)
                        .onTapGesture {
                            cardTapped(index)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
            }
            .padding()

            Button("Restart Game") {
                setupGame()
            }
            .padding(.top, 10)
        }
        .padding()
        .onAppear {
            setupGame()
        }
    }

    // MARK: - Game Logic

    func setupGame() {
        // 4 colors × 2 + 1 extra purple
        colorIndexes = [0,0,1,1,2,2,3,3,4] // last one is purple
        colorIndexes.shuffle()

        revealed = Array(repeating: false, count: 9)
        matched = Array(repeating: false, count: 9)

        firstIndex = nil
        secondIndex = nil
        isBusy = false
        statusText = "Match the Colors"
    }

    func cardColor(_ index: Int) -> Color {
        if revealed[index] || matched[index] {
            return colors[colorIndexes[index]]
        } else {
            return .gray
        }
    }

    func cardTapped(_ index: Int) {
        // Ignore taps on matched or the single purple cube
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

        let firstColor = colorIndexes[firstIndex!]
        let secondColor = colorIndexes[secondIndex!]

        if firstColor == secondColor && firstColor != 4 { // exclude purple
            matched[firstIndex!] = true
            matched[secondIndex!] = true
            statusText = "Matched ✅"

            let allMatched = matched.enumerated().allSatisfy { index, val in
                if colorIndexes[index] == 4 { return true } // ignore purple
                return val
            }

            if allMatched {
                statusText = "🎉 You Win! 🎉"
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                resetSelection()
            }
        } else {
            statusText = "Not Matched ❌"

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

// MARK: - Medium Game 5x5 (12 double + 1 unique color)
struct MediumGameView: View {

    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan, .mint, .indigo, .teal, .brown, .gray]
    let colorNames: [String] = ["Red","Blue","Green","Yellow","Purple","Orange","Pink","Cyan","Mint","Indigo","Teal","Brown","Unique"]

    @State private var colorIndexes: [Int] = []
    @State private var revealed: [Bool] = Array(repeating: false, count: 25)
    @State private var matched: [Bool] = Array(repeating: false, count: 25)
    @State private var firstIndex: Int? = nil
    @State private var secondIndex: Int? = nil
    @State private var isBusy = false
    @State private var statusText = "Match the Colors"

    var body: some View {
        VStack(spacing: 20) {
            Text("Medium Mode")
                .font(.title)
                .fontWeight(.semibold)

            Text(statusText)
                .font(.headline)
                .padding(.top, 10)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                ForEach(0..<25, id: \.self) { index in
                    Rectangle()
                        .fill(cardColor(index))
                        .frame(height: 70)
                        .cornerRadius(10)
                        .onTapGesture { cardTapped(index) }
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                }
            }
            .padding()

            Button("Restart Game") { setupGame() }
                .padding(.top, 10)
        }
        .padding()
        .onAppear { setupGame() }
    }

    func setupGame() {
        colorIndexes = Array(0..<12).flatMap { [$0,$0] } // 12 doubles
        colorIndexes.append(12) // unique color
        colorIndexes.shuffle()

        revealed = Array(repeating: false, count: 25)
        matched = Array(repeating: false, count: 25)
        firstIndex = nil
        secondIndex = nil
        isBusy = false
        statusText = "Match the Colors"
    }

    func cardColor(_ index: Int) -> Color { (revealed[index] || matched[index]) ? colors[colorIndexes[index]] : .gray }

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
        let firstColor = colorIndexes[firstIndex!]
        let secondColor = colorIndexes[secondIndex!]

        if firstColor == secondColor && firstColor != 12 { // unique color excluded
            matched[firstIndex!] = true
            matched[secondIndex!] = true
            statusText = "Matched ✅"

            let allMatched = matched.enumerated().allSatisfy { index, val in
                if colorIndexes[index] == 12 { return true }
                return val
            }

            if allMatched { statusText = "🎉 You Win! 🎉" }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { resetSelection() }
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

// MARK: - Hard Mode Placeholder
struct HardGameView: View {
    var body: some View {
        VStack {
            Text("Hard Mode Coming Soon 🔥")
                .font(.title)
                .fontWeight(.bold)
                .padding()
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
