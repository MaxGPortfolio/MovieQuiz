//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Максим on 19.11.2025.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private enum ComparisonType {
        case greater
        case less
    }
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    private func makeQuestion(for movie: MostPopularMovie, imageData: Data) -> QuizQuestion {
        let rating = Float(movie.rating) ?? 0

        let comparison: ComparisonType = Bool.random() ? .greater : .less

        let threshold: Float
        switch rating {
        case 8.5...10:
            threshold = [8, 9].randomElement()!
        case 7...8.5:
            threshold = [6, 7, 8].randomElement()!
        case 5...7:
            threshold = [4, 5, 6].randomElement()!
        default:
            threshold = [3, 4, 5].randomElement()!
        }

        let thresholdText = String(Int(threshold))

        let text: String
        let correctAnswer: Bool

        switch comparison {
        case .greater:
            text = "Рейтинг этого фильма больше чем \(thresholdText)?"
            correctAnswer = rating > threshold
        case .less:
            text = "Рейтинг этого фильма меньше чем \(thresholdText)?"
            correctAnswer = rating < threshold
        }

        return QuizQuestion(
            image: imageData,
            text: text,
            correctAnswer: correctAnswer
        )
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }

            var imageData = Data()

            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }

            let question = self.makeQuestion(for: movie, imageData: imageData)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    /*
     private let questions: [QuizQuestion] = [
     QuizQuestion(
     image: "The Godfather",
     text: "Рейтинг этого фильма больше чем 6?",
     correctAnswer: true
     ),
     QuizQuestion(
     image: "The Dark Knight",
     text: "Рейтинг этого фильма больше чем 6?",
     correctAnswer: true
     ),
     QuizQuestion(
     image: "Kill Bill",
     text: "Рейтинг этого фильма больше чем 6?",
     correctAnswer: true
     ),
     QuizQuestion(
     image: "The Avengers",
     text: "Рейтинг этого фильма больше чем 6?",
     correctAnswer: true
     ),
     QuizQuestion(
     image: "Deadpool",
     text: "Рейтинг этого фильма больше чем 6?",
     correctAnswer: true
     ),
     QuizQuestion(
     image: "The Green Knight",
     text: "Рейтинг этого фильма больше чем 6?",
     correctAnswer: true
     ),
     QuizQuestion(
     image: "Old",
     text: "Рейтинг этого фильма больше чем 6?",
     correctAnswer: false
     ),
     QuizQuestion(
     image: "The Ice Age Adventures of Buck Wild",
     text: "Рейтинг этого фильма больше чем 6?",
     correctAnswer: false
     ),
     QuizQuestion(
     image: "Tesla",
     text: "Рейтинг этого фильма больше чем 6?",
     correctAnswer: false
     ),
     QuizQuestion(
     image: "Vivarium",
     text: "Рейтинг этого фильма больше чем 6?",
     correctAnswer: false
     )
     ]
     */
}
