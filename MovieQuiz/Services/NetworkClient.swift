//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Максим on 07.12.2025.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

private enum HTTPStatus {
    static let successMin = 200
    static let successMax = 300
}

struct NetworkClient: NetworkRouting {

    private enum NetworkError: Error {
        case codeError
        case noData
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                handler(.failure(error))
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode < HTTPStatus.successMin || response.statusCode >= HTTPStatus.successMax {
                handler(.failure(NetworkError.codeError))
                return
            }
            guard let data = data else {
                handler(.failure(NetworkError.noData))
                return
            }
            handler(.success(data))
        }
        
        task.resume()
    }
}
