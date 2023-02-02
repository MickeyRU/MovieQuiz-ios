//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Павел Афанасьев on 31.01.2023.
//

import UIKit

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
    
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var totalAccuracy: Double {
        get {
            let correctAnswers = userDefaults.integer(forKey: Keys.correct.rawValue)
            let totalAnswers = userDefaults.integer(forKey: Keys.total.rawValue)
            return Double(correctAnswers * 100 / totalAnswers)
        }
        
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data)
            else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue)
            else {
                print("Невозможно сохранить результат лучшей игры")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    
    // Сохранение текущего результата игры
    func store(correct count: Int, total amount: Int) {
        // Сверяем текущий результат игры с сохранненым рекордом
        let currentGameResult = GameRecord(correct: count, total: amount, date: Date())
        if bestGame.isNotRecordAnymore(new: currentGameResult) {
            bestGame = currentGameResult
        }
        gamesCount += 1
        
        var savedCorrectAnswers = userDefaults.integer(forKey: Keys.correct.rawValue)
        savedCorrectAnswers += count
        userDefaults.set(savedCorrectAnswers, forKey: Keys.correct.rawValue)
        
        var savedTotalAnswers = userDefaults.integer(forKey: Keys.total.rawValue)
        savedTotalAnswers += amount
        userDefaults.set(savedTotalAnswers, forKey: Keys.total.rawValue)
    
    }
}
