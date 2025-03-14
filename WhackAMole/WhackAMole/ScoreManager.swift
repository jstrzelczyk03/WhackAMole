//
//  ScoreManager.swift
//  WhackAMole
//
//  Created by Jakub Strzelczyk on 6/27/24.
//

import Foundation

struct ScoreRecord: Identifiable, Codable {
    let id = UUID()
    let playerName: String
    var points: Double
    let difficulty: Difficulty
    let timeRemaining: Int
}
class ScoreManager {
    static let shared = ScoreManager()

    private let scoresKey = "highScores"
    private(set) var scores: [ScoreRecord] = []

    init() {
        loadScores()
    }

    func addScore(_ score: ScoreRecord) {
        guard score.points > 0 else {
            return
        }

        if let existingIndex = scores.firstIndex(where: { $0.playerName == score.playerName && $0.difficulty == score.difficulty }) {
            if scores[existingIndex].points < score.points {
                scores[existingIndex].points = score.points
            }
        } else {
            scores.append(score)
        }
        saveScores()
    }

    private func saveScores() {
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: scoresKey)
        }
    }

    private func loadScores() {
        if let savedData = UserDefaults.standard.data(forKey: scoresKey),
           let decoded = try? JSONDecoder().decode([ScoreRecord].self, from: savedData) {
            scores = decoded
        }
    }

    func resetScores() {
        scores = []
        saveScores()
    }
}
