//
//  ContentView.swift
//  WhackAMole
//
//  Created by Jakub Strzelczyk on 6/27/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var playerName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Enter Your Nickname")
                    .font(.headline)
                    .padding()
                
                TextField("Nickname", text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Text("Select Difficulty")
                    .font(.headline)
                    .padding()

                Picker("Difficulty", selection: $selectedDifficulty) {
                    Text("Easy").tag(Difficulty.easy)
                    Text("Medium").tag(Difficulty.medium)
                    Text("Hard").tag(Difficulty.hard)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                NavigationLink(
                    destination: GameView(viewModel: GameViewModel(difficulty: selectedDifficulty, playerName: playerName)),
                    label: {
                        Text("Start Game")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    })

                VStack(alignment: .leading, spacing: 10) {
                    Text("Points Guide:")
                        .font(.headline)
                    HStack {
                        Text("🟡 Golden Mole:")
                        Spacer()
                        Text("+5 points")
                    }
                    HStack {
                        Text("🟤 Brown Mole:")
                        Spacer()
                        Text("+1 point")
                    }
                    HStack {
                        Text("⚫ Black Mole:")
                        Spacer()
                        Text("-3 points")
                    }
                    HStack {
                        Text("⬜ Miss:")
                        Spacer()
                        Text("-1 point")
                    }
                }
                .font(.subheadline)
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                .padding()

                NavigationLink(
                    destination: ScoreboardView(),
                    label: {
                        Text("View Scores")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    })
                NavigationLink(
                    destination: RulesView(),
                    label: {
                        Text("Game Rules")
                            .font(.title)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    })
                    .padding(.bottom, 20)
            }
        }
    }
}

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.presentationMode) var presentationMode

    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    if !viewModel.isPaused && !viewModel.isGameOver {
                        viewModel.missMole()
                    }
                }

            VStack {
                HStack {
                    Text(levelGoalText(for: viewModel.gameScore.difficulty))
                        .font(.headline)
                        .padding()
                }
                Text("Time: \(viewModel.gameScore.timeRemaining)")
                    .font(.headline)
                Text("Score: \(viewModel.gameScore.points)")
                    .font(.headline)

                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<viewModel.moles.count, id: \.self) { index in
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 100, height: 100)
                                .onTapGesture {
                                    if viewModel.moles[index].state == .hidden {
                                        viewModel.missMole()
                                    }
                                }

                            if viewModel.moles[index].state != .hidden {
                                Button(action: {
                                    viewModel.hitMole(viewModel.moles[index])
                                }) {
                                    MoleView(isGolden: viewModel.moles[index].isGolden, isBlack: viewModel.moles[index].isBlack)
                                }
                                .frame(width: 100, height: 100)
                                .background(Color.clear)
                                .buttonStyle(PlainButtonStyle())
                                .simultaneousGesture(TapGesture().onEnded {
                                    // Prevent propagation to parent tap gesture
                                })
                            }
                        }
                    }
                }

                Button(action: {
                    viewModel.togglePause()
                }) {
                    Text(viewModel.isPaused ? "Resume" : "Pause")
                        .font(.title)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .onAppear {
            viewModel.resetGame(with: viewModel.gameScore.difficulty)
        }
        .alert(isPresented: $viewModel.isGameOver) {
            let formattedScore = String(format: "%.2f", viewModel.cumulativeScore)
            let message = viewModel.gameCompleted ? "Congratulations! You've completed the game with a Total Score of \(formattedScore)." : viewModel.gameScore.points >= pointsToWin(for: viewModel.gameScore.difficulty) ? "You've won this level! Your Total Score is \(formattedScore). Do you want to move to the next level?" : "Time's up! Your Total Score is \(formattedScore). Do you want to try again?"
            let primaryButton = viewModel.gameCompleted ? Alert.Button.default(Text("Main Menu")) {
                presentationMode.wrappedValue.dismiss()
            } : Alert.Button.default(Text(viewModel.gameScore.points >= pointsToWin(for: viewModel.gameScore.difficulty) ? "Next Level" : "Retry")) {
                if viewModel.gameScore.points >= pointsToWin(for: viewModel.gameScore.difficulty) {
                    viewModel.increaseDifficulty()
                } else {
                    viewModel.resetGame(with: viewModel.gameScore.difficulty)
                }
            }
            
            return viewModel.gameCompleted ? Alert(title: Text("Game Over"), message: Text(message), dismissButton: primaryButton) : Alert(title: Text("Game Over"), message: Text(message), primaryButton: primaryButton, secondaryButton: .cancel(Text("Main Menu")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func levelGoalText(for difficulty: Difficulty) -> String {
        switch difficulty {
        case .easy:
            return "Score 20 points to win the level"
        case .medium:
            return "Score 30 points to win the level"
        case .hard:
            return "Score 40 points to win the level"
        }
    }
    
    private func pointsToWin(for difficulty: Difficulty) -> Int {
        switch difficulty {
        case .easy:
            return 20
        case .medium:
            return 30
        case .hard:
            return 40
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
import SwiftUI

struct RulesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Game Rules")
                    .font(.largeTitle)
                    .padding()

                Text("1. Objective:")
                    .font(.headline)
                Text("The goal of the game is to score as many points as possible by hitting the moles that appear on the screen. To pass a level, you must score at least the required number of points for that difficulty level.")

                Text("2. Scoring:")
                    .font(.headline)
                Text("🟡 Golden Mole: +5 points")
                Text("🟤 Brown Mole: +1 point")
                Text("⚫ Black Mole: -3 points")
                Text("⬜ Miss: -1 point")

                Text("3. Points to Win:")
                    .font(.headline)
                Text("Each level requires a different number of points to win:")
                Text(" - Easy level: 20 points")
                Text(" - Medium level: 30 points")
                Text(" - Hard level: 40 points")

                Text("4. Total Score Calculation:")
                    .font(.headline)
                Text("The total score is calculated based on your score in the level, the difficulty level, and the remaining time. If you achieve the required points, you will receive additional points for the remaining time:")
                Text("Total Score = Required Points * Difficulty Multiplier * (1 + (remaining time / 60))")
                Text("The difficulty multiplier is:")
                Text(" - Easy level: 1.0")
                Text(" - Medium level: 2.0")
                Text(" - Hard level: 3.0")
                Text("If you do not achieve the required points, the total score is calculated as:")
                Text("Total Score = Level Score * Difficulty Multiplier")

                Text("5. Difficulty Levels:")
                    .font(.headline)
                Text("The game can be started at three difficulty levels: easy, medium, and hard. Each level has different mole appearance speeds and different numbers of moles to hit.")

                Text("6. Game Time:")
                    .font(.headline)
                Text("Each level lasts 60 seconds. When the time runs out, the game ends and the points are calculated.")

                Text("7. Winning and Losing:")
                    .font(.headline)
                Text("If you score the required points before time runs out, you win the level and can proceed to the next. If you do not score enough points, the game ends.")

                Text("8. Pause:")
                    .font(.headline)
                Text("You can pause the game at any time using the 'Pause' button. The game resumes when you press the 'Resume' button.")
            }
            .padding()
        }
    }
}
struct ScoreboardView: View {
    var body: some View {
        VStack {
            Text("High Scores")
                .font(.largeTitle)
                .padding()
            
            List(ScoreManager.shared.scores) { score in
                VStack(alignment: .leading) {
                    HStack {
                        Text("Player: \(score.playerName)")
                        Spacer()
                        Text("Difficulty: \(score.difficulty.rawValue.capitalized)")
                    }
                    HStack {
                        Text(String(format: "Points: %.2f", score.points))
                        Spacer()
                        Text("Time remaining: \(score.timeRemaining)s")
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
    }
}
