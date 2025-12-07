//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Максим on 28.11.2025.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date

    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
