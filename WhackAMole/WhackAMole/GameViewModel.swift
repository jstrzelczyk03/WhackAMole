//
//  GameViewModel.swift
//  WhackAMole
//
//  Created by Jakub Strzelczyk on 6/27/24.
//

import SwiftUI
import Combine
import AVFoundation

class GameViewModel: ObservableObject {
    @Published var moles: [Mole] = []
    @Published var gameScore: GameScore
    @Published var isGameOver = false
    @Published var isPaused = false
    @Published var hitPoints: Double = 0
    @Published var cumulativeScore: Double = 0.0
    @Published var gameCompleted = false

    private var timer: Timer?
    private var moleTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init(difficulty: Difficulty = .easy, playerName: String) {
        self.gameScore = GameScore(timeRemaining: 60, difficulty: difficulty, playerName: playerName)
        resetGame(with: difficulty)
    }

    func resetGame(with difficulty: Difficulty) {
        isGameOver = false
        isPaused = false
        gameCompleted = false
        gameScore.points = 0
        hitPoints = 0
        gameScore.timeRemaining = 60
        gameScore.difficulty = difficulty
        moles = generateMoles(for: difficulty)

        startTimers()
    }

    private func startTimers() {
        stopTimers()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.gameTick()
        }

        startMoleTimer()
    }

    private func startMoleTimer() {
        let moleVisibilityDuration: TimeInterval
        switch gameScore.difficulty {
        case .easy:
            moleVisibilityDuration = 1.9
        case .medium:
            moleVisibilityDuration = 1.7
        case .hard:
            moleVisibilityDuration = 1.4
        }

        moleTimer?.invalidate()
        moleTimer = Timer.scheduledTimer(withTimeInterval: moleVisibilityDuration, repeats: true) { [weak self] _ in
            self?.updateMolesVisibility()
        }
    }

    func gameTick() {
        if gameScore.timeRemaining > 0 {
            gameScore.timeRemaining -= 1
        } else {
            endGame()
        }
        checkGameOver()
    }

    func hitMole(_ mole: Mole) {
        if let index = moles.firstIndex(where: { $0.id == mole.id }) {
            if mole.isGolden {
                gameScore.points += 5
                hitPoints += 5
            } else if mole.isBlack {
                gameScore.points -= 3
                hitPoints -= 3
            } else {
                gameScore.points += 1
                hitPoints += 1
            }

            moles[index].state = .hidden
            checkGameOver()
        }
    }

    func missMole() {
        if !isPaused && !isGameOver {
            gameScore.points -= 1
            checkGameOver()
        }
    }

    private func checkGameOver() {
        if gameScore.points >= pointsToWin(for: gameScore.difficulty) {
            endGame()
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

    private func generateMoles(for difficulty: Difficulty) -> [Mole] {
        var newMoles: [Mole] = []
        let moleCount: Int
        switch difficulty {
        case .easy:
            moleCount = 9
        case .medium:
            moleCount = 12
        case .hard:
            moleCount = 15
        }

        for _ in 0..<moleCount {
            let random = Int.random(in: 0...10)
            let state: MoleState = .hidden

            if random == 0 {
                newMoles.append(Mole(isGolden: true, isBlack: false, state: state))
            } else if random == 1 {
                newMoles.append(Mole(isGolden: false, isBlack: true, state: state))
            } else {
                newMoles.append(Mole(isGolden: false, isBlack: false, state: state))
            }
        }
        return newMoles
    }

    private func updateMolesVisibility() {
        for index in moles.indices {
            if moles[index].state == .hidden && Bool.random() {
                moles[index].state = .emerging
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.moles[index].state = .visible
                }
            } else if moles[index].state == .visible {
                moles[index].state = .hidden
            }
        }
    }

    func endGame() {
        if !isGameOver {
            isGameOver = true
            stopTimers()

            let pointsMultiplier: Double
            switch gameScore.difficulty {
            case .easy:
                pointsMultiplier = 1.0
            case .medium:
                pointsMultiplier = 2.0
            case .hard:
                pointsMultiplier = 3.0
            }

            var calculatedScore: Double
            if gameScore.points >= pointsToWin(for: gameScore.difficulty) {
                let timeBonus = Double(gameScore.timeRemaining) / 60.0
                calculatedScore = Double(pointsToWin(for: gameScore.difficulty)) * pointsMultiplier * (1 + timeBonus)
            } else {
                calculatedScore = Double(gameScore.points) * pointsMultiplier
            }

            cumulativeScore += calculatedScore

            if gameScore.difficulty == .hard && gameScore.points >= pointsToWin(for: gameScore.difficulty) {
                gameCompleted = true
            }

            saveScore()
        }
    }

    func restartGame() {
        resetGame(with: .easy)
    }

    func increaseDifficulty() {
        switch gameScore.difficulty {
        case .easy:
            resetGame(with: .medium)
        case .medium:
            resetGame(with: .hard)
        case .hard:
            isGameOver = true
            gameCompleted = true
        }
    }

    func togglePause() {
        isPaused.toggle()
        if isPaused {
            stopTimers()
        } else {
            startTimers()
        }
    }

    private func stopTimers() {
        timer?.invalidate()
        moleTimer?.invalidate()
    }

    private func saveScore() {
        let scoreRecord = ScoreRecord(playerName: gameScore.playerName, points: cumulativeScore, difficulty: gameScore.difficulty, timeRemaining: gameScore.timeRemaining)
        ScoreManager.shared.addScore(scoreRecord)
    }
}
