//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Максим on 21.11.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
