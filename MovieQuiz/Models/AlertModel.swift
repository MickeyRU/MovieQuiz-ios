//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Павел Афанасьев on 30.01.2023.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
