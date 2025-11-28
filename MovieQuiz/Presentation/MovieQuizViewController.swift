import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - Outlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!

    // MARK: - Properties

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private let alertPresenter = AlertPresenter()
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Constants
    
    private enum UIConstants {
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 8
        static let answerDelay: TimeInterval = 1.0
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self)
        showCurrentQuestion()
        
        setButtonsEnabled(true)
    }

    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showQuiz(step: viewModel)
        }
    }

    // MARK: - Actions

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard yesButton.isEnabled && noButton.isEnabled else { return }
        guard let currentQuestion = currentQuestion else { return }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard yesButton.isEnabled && noButton.isEnabled else { return }
        guard let currentQuestion = currentQuestion else { return }
        
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }

    // MARK: - Private Methods

    private func setButtonsEnabled(_ enabled: Bool) {
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }

    private func showQuiz(step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func showCurrentQuestion() {
        questionFactory?.requestNextQuestion()
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = UIConstants.cornerRadius
    }

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
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "",
                buttonText: "Сыграть ещё раз"
            )
            showQuiz(result: viewModel)
            imageView.layer.borderWidth = 0
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            setButtonsEnabled(true)
            imageView.layer.borderWidth = 0
        }
    }

    private func showQuiz(result: QuizResultsViewModel) {
        let bestGame = statisticService.bestGame
        let totalAccuracyText = String(format: "%.2f", statisticService.totalAccuracy)
        
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(totalAccuracyText)%
        """

        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
            self.setButtonsEnabled(true)
            self.imageView.layer.borderWidth = 0
        }
        
        alertPresenter.show(in: self, model: alertModel)
    }
}
