import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var questionNumberLabel: UILabel!
    @IBOutlet private weak var filmPosterImageView: UIImageView!
    @IBOutlet private weak var questionTextLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // Алерт
    private var alertPresenter: ResultAlertPresenter?
    
    // Статистика
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
    // Презентер
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = ResultAlertPresenter(alertPresenterDelegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
    }

    // MARK: - Actions
    
    @IBAction private func noButtonPressed(_ sender: UIButton) {
        presenter.noButtonPressed()
    }
    
    @IBAction private func yesButtonPressed(_ sender: UIButton) {
        presenter.yesButtonPressed()
    }
    
    // MARK: - Private functions
    
    // Показ результата игры
    func show(quiz result: QuizResultsViewModel) {
        statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        let bestGame = statisticService.bestGame
        let totalGamesCountText = "\nКоличество сыгранных квизов: \(statisticService.gamesCount)"
        let recordText = "\nРекорд: \(bestGame.correct)/\(presenter.questionsAmount) (\(bestGame.date.dateTimeString))"
        let accuracyText = "\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let alerModel = AlertModel(
            title: result.title,
            message: result.text + totalGamesCountText + recordText + accuracyText,
            buttonText: result.buttonText) { [weak self] in
                guard let self = self else {
                    return
                }
                self.presenter.restartGame()
            }
        alertPresenter?.showAlert(with: alerModel)
    }
    
    // Показ вопроса квиза на экране
    func show(quiz step: QuizStepViewModel) {
        self.filmPosterImageView.image = step.image
        self.questionTextLabel.text = step.question
        self.questionNumberLabel.text = step.questionNumber
    }
    
    // Результат ответа пользователя на вопрос квиза
    func showAnswerResult(isAnswerCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isAnswerCorrect)
        
        filmPosterImageView.layer.masksToBounds = true
        filmPosterImageView.layer.borderWidth = 8
        filmPosterImageView.layer.borderColor = isAnswerCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.filmPosterImageView.layer.borderWidth = 0
            self.presenter.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    func hideLoadingIndicator() {
           activityIndicator.isHidden = true
       }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
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
}
