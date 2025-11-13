import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Models

    private struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }

    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }

    private struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }

    // MARK: - Outlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!


    // MARK: - Properties

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

    private var currentQuestionIndex = 0
    private var correctAnswers = 0

    // MARK: - Constants
    private enum UIConstants {
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 8
        static let answerDelay: TimeInterval = 1.0
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        showCurrentQuestion()
        setButtonsEnabled(true)
    }


    // MARK: - Actions

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard yesButton.isEnabled && noButton.isEnabled else { return }
        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard yesButton.isEnabled && noButton.isEnabled else { return }
        showAnswerResult(isCorrect: !questions[currentQuestionIndex].correctAnswer)
    }


    // MARK: - Private Methods

    private func setButtonsEnabled(_ enabled: Bool) {
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
    }

    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
        return questionStep
    }

    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func showQuiz(step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    // показ первого вопроса
    private func showCurrentQuestion() {
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        showQuiz(step: viewModel)
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = UIConstants.cornerRadius
    }

    // метод меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        setButtonsEnabled(false)
        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = UIConstants.borderWidth
        imageView.layer.borderColor = isCorrect ? UIColor.YPGreen.cgColor : UIColor.YPRed.cgColor
        imageView.layer.cornerRadius = UIConstants.cornerRadius

        DispatchQueue.main.asyncAfter(deadline: .now() + UIConstants.answerDelay) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }

    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/\(questions.count)"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            showQuiz(result: viewModel)
            imageView.layer.borderWidth = 0
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            showQuiz(step: viewModel)
            setButtonsEnabled(true)
            imageView.layer.borderWidth = 0
        }
    }

    // приватный метод для показа результатов раунда квиза
    private func showQuiz(result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.showQuiz(step: viewModel)
            self.setButtonsEnabled(true)
            self.imageView.layer.borderWidth = 0
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
