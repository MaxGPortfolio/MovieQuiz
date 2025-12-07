//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Максим on 21.11.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
