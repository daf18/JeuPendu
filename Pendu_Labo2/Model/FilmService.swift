//
//  FilmService.swift
//  Pendu_Labo2
//
//  Created by MAC on 2022-05-28.
//

import Foundation

struct FilmData: Decodable {
    let Title: String
    let Year: String
    let Rated: String
    let Released: String
    let Runtime: String
    let Genre: String
    let Director: String
    let Writer: String
    let Actors: String
    let Plot: String
    let Language: String
    let Country: String
    let Awards: String
    let Poster: String
    let Ratings: [FilmRatings]
//    let Metascore: String
//    let imdbRating: String
//    let imdbVotes: String
//    let imdbID: String
//    let DVD: String
//    let BoxOffice: String
//    let Response: String
//    let Production: String
//    let Website: String
}

struct FilmRatings: Decodable {
    let Source: String
    let Value: String
}

class FilmService {
    static let shared = FilmService()
    private init() {}

    private let baseUrl = "http://www.omdbapi.com/?apikey=3c8aba6a&i=tt00"
    private var task: URLSessionDataTask?

    private var session = URLSession(configuration: .default)

    init(session: URLSession) {
        self.session = session
    }

    func getFilm(randomId: String, callback: @escaping (Bool, FilmData?) -> Void) {
        
        guard let url = URL(string: baseUrl + randomId) else {
            callback(false, nil)
            return
        }

        print(url)
        task?.cancel()
        task = session.dataTask(with: url) { (data, response, error) in
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

                var myFilm: FilmData?
                if let safeData = data {
                    
                    do {
                        let decoder = JSONDecoder()
                        myFilm = try decoder.decode(FilmData.self, from: safeData)
                        callback(true, myFilm)
                    } catch DecodingError.dataCorrupted(let context) {
                        print(context)
                    } catch DecodingError.keyNotFound(let key, let context) {
                        print("Key '\(key)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch DecodingError.valueNotFound(let value, let context) {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch DecodingError.typeMismatch(let type, let context) {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch {
                        print("error: ", error)
                    }
                }
            }
        }

    task?.resume()
    }
}
