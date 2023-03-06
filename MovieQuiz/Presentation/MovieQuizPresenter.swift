//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Павел Афанасьев on 06.03.2023.
//

import UIKit

final class MovieQuizPresenter {
    // Общее число вопросов квиза
    let questionsAmount: Int = 10
    
    // Вспомогательная переменная для вычисления номера отображаемого вопроса на экране
    private var currentQuestionIndex: Int = 0
    
    // Текущий вопрос, отображаемый на экране
    var currentQuestion: QuizQuestion?
    
    weak var viewController: MovieQuizViewController?
    
    // MARK: - Methods
    func yesButtonPressed() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        viewController?.showAnswerResult(isAnswerCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonPressed() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        viewController?.showAnswerResult(isAnswerCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // Конвертация модели вопроса квиза в модель для отображения след вопроса на экране
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
}
