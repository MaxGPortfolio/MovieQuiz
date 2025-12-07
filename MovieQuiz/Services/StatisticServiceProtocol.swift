//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Максим on 27.11.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}

