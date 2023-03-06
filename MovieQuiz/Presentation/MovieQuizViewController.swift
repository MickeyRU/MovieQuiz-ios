import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var questionNumberLabel: UILabel!
    @IBOutlet private weak var filmPosterImageView: UIImageView!
    @IBOutlet private weak var questionTextLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // Вспомогательная переменная для подсчета данных пользователем верных ответов
    private var correctAnswers: Int = 0
    
    // Фабрика, где происходит генерация вопроса
    private var questionFactory: QuestionFactoryProtocol?
    
    // Текущий вопрос, отображаемый на экране
    private var currentQuestion: QuizQuestion?
    
    // Алерт
    private var alertPresenter: ResultAlertPresenter?
    
    // Статистика
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
    // Презентер
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = ResultAlertPresenter(alertPresenterDelegate: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        presenter.viewController = self
        
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    // Получение следующего вопроса квиза из базы
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        let viewModel = presenter.convert(model: question)
        currentQuestion = question
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonPressed(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonPressed()
    }
    
    @IBAction private func yesButtonPressed(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonPressed()
    }
    
    // MARK: - Private functions
    
    // Показ результата игры
    private func show(quiz result: QuizResultsViewModel) {
        statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
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
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        alertPresenter?.showAlert(with: alerModel)
    }
    
    // Показ вопроса квиза на экране
    private func show(quiz step: QuizStepViewModel) {
        self.filmPosterImageView.image = step.image
        self.questionTextLabel.text = step.question
        self.questionNumberLabel.text = step.questionNumber
    }
    
    // Результат ответа пользователя на вопрос квиза
    func showAnswerResult(isAnswerCorrect: Bool) {
        if isAnswerCorrect {
            correctAnswers += 1
        }
        filmPosterImageView.layer.masksToBounds = true
        filmPosterImageView.layer.borderWidth = 8
        filmPosterImageView.layer.borderColor = isAnswerCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.filmPosterImageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    // Показ следующего вопрос квиза или результата игры
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)",
                buttonText: "Сыграть ещё раз")
            show(quiz: result)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator(){
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModal = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.loadData()
        }
        
        alertPresenter?.showAlert(with: alertModal)
    }
}
