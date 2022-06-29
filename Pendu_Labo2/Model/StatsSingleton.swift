//
//  StatsSingleton.swift
//  Pendu_Labo2
//
//  Created by MAC on 2022-06-01.
//

import Foundation

class StatsSingleton {
    static var shared = StatsSingleton()
    
    var stateLengthDictionaire: Int
    var stateLengthFilm: Int
    var fifthStateDictionaire: Int
    var fifthStateFilm: Int
    
    private init(){
        self.stateLengthFilm = 0
        self.stateLengthDictionaire = 0
        self.fifthStateDictionaire = 0
        self.fifthStateFilm = 0
    }
}
