//
//  WordService.swift
//  Pendu_Labo2
//
//  Created by Andreea Draghici on 2022-05-26.
//

import Foundation

struct WordData: Decodable {
    let word: String
    
    init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            word = try container.decode(String.self)
    }

}

class WordService {
  
    private static let wordUrl = URL(string: "https://random-word-api.herokuapp.com/word")!
    
    static func getWord(callback: @escaping (Bool, String?) -> Void) {
        var request = URLRequest(url: wordUrl)
        request.httpMethod = "GET"

    let session = URLSession(configuration: .default)

        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    callback(false, nil)
                    print(error!)
                    return
                }
                
                guard let response = response as? HTTPURLResponse,response.statusCode == 200 else {
                    callback(false, nil)
                    return
                }

                if let safeData = data {
                    let myWord = try? JSONDecoder().decode(WordData.self, from: safeData)
                    let randomWord = myWord!.word
                    callback(true, randomWord)
                    
                }
            }
        }

    task.resume()
    }
}
