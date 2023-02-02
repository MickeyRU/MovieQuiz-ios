//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Павел Афанасьев on 30.01.2023.
//

import UIKit

class ResultAlertPresenter {
    weak var alertPresenterDelegate: MovieQuizViewController?
    
    init(alertPresenterDelegate: MovieQuizViewController) {
        self.alertPresenterDelegate = alertPresenterDelegate
    }
    
    func showAlert (with model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        alertPresenterDelegate?.present(alert, animated: true, completion: nil)
    }
}
