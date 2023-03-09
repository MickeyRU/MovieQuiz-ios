import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var questionNumberLabel: UILabel!
    @IBOutlet private weak var filmPosterImageView: UIImageView!
    @IBOutlet private weak var questionTextLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: ResultAlertPresenter?
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = ResultAlertPresenter(alertPresenterDelegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        
        showLoadingIndicator()
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonPressed(_ sender: UIButton) {
        presenter.noButtonPressed()
    }
    
    @IBAction private func yesButtonPressed(_ sender: UIButton) {
        presenter.yesButtonPressed()
    }
    
    // MARK: - Methods
    
    func show(quiz step: QuizStepViewModel) {
        self.filmPosterImageView.image = step.image
        self.questionTextLabel.text = step.question
        self.questionNumberLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alert = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText) { [weak self] in
                guard let self = self else {
                    return
                }
                self.presenter.restartGame()
            }
        alertPresenter?.showAlert(with: alert)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        filmPosterImageView.layer.masksToBounds = true
        filmPosterImageView.layer.borderWidth = 8
        filmPosterImageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModal = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alertPresenter?.showAlert(with: alertModal)
    }
    
    func hideImageBorder() {
        filmPosterImageView.layer.borderWidth = 0
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
}
