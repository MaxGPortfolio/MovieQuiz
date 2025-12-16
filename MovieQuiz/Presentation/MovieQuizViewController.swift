import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    // MARK: - Outlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties

    private var presenter: MovieQuizPresenter!
    private let alertPresenter = AlertPresenter()
    
    // MARK: - Constants
    
    private enum UIConstants {
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 8
    }
    
    private enum AlertText {
        static let networkErrorTitle = "Что-то пошло не так("
        static let retryButton = "Попробовать еще раз"
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = MovieQuizPresenter(viewController: self)

        imageView.layer.cornerRadius = UIConstants.cornerRadius
        setButtonsEnabled(true)
    }

    // MARK: - Actions

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    // MARK: - Methods

    private func setButtonsEnabled(_ enabled: Bool) {
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
    }

    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: AlertText.networkErrorTitle,
            message: message,
            buttonText: AlertText.retryButton
        ) { [weak self] in
            guard let self else { return }
            
            self.presenter.restartGame()
        }
        
        alertPresenter.show(in: self, model: model)
    }

    func showQuiz(step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 0

        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        setButtonsEnabled(true)
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        setButtonsEnabled(false)

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = UIConstants.borderWidth
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.YPGreen.cgColor : UIColor.YPRed.cgColor
        imageView.layer.cornerRadius = UIConstants.cornerRadius
    }

    func show(quiz step: QuizStepViewModel) {
        showQuiz(step: step)
    }

    func show(quiz result: QuizResultsViewModel) {
        showQuiz(result: result)
    }


    private func showQuiz(result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()

        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alertPresenter.show(in: self, model: alertModel)
        DispatchQueue.main.async { [weak self] in
            self?.presentedViewController?.view.accessibilityIdentifier = "GameFinishAlert"
        }
    }
}
