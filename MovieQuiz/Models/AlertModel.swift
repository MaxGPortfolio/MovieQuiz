//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Максим on 22.11.2025.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var complection: () -> Void
}
