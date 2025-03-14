//
//  Mole.swift
//  WhackAMole
//
//  Created by Jakub Strzelczyk on 6/27/24.
//

import Foundation

enum Difficulty: String, Codable {
    case easy, medium, hard
}

enum MoleState {
    case hidden
    case emerging
    case visible
}

struct Mole: Identifiable {
    let id = UUID()
    let isGolden: Bool
    let isBlack: Bool
    var state: MoleState = .hidden
}

struct GameScore {
    var points: Int = 0
    var timeRemaining: Int
    var difficulty: Difficulty
    var playerName: String
}
