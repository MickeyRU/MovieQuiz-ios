//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Павел Афанасьев on 29.01.2023.
//

import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
