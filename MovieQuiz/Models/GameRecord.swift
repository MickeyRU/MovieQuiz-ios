//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Павел Афанасьев on 31.01.2023.
//

import UIKit

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isNotRecordAnymore (new game: GameRecord) -> Bool {
        correct < game.correct
    }
}
