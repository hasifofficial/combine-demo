//
//  API.swift
//  combine-demo
//
//  Created by Mohammad Hasif Afiq on 29/05/2023.
//

import Foundation
import Combine

class API {
    static let shared = API()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        
    }
    
    // API call method using completion approach
    func request<T: Decodable>(endpoint: Endpoint, type: T.Type, completion: @escaping ((Result<T, Error>) -> Void)) {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header

        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else { return completion(.failure(RequestError.noResponse)) }
            
            switch response.statusCode {
            case 200...299:
                guard let data = data,
                      let decodedResponse = try? JSONDecoder().decode(type, from: data) else { return completion(.failure(RequestError.decode)) }
                return completion(.success(decodedResponse))
            case 401:
                return completion(.failure(RequestError.unauthorized))
            default:
                return completion(.failure(RequestError.unexpectedStatusCode))
            }
        }
        .resume()
    }

    // API call method using combine approach
    func request<T: Decodable>(endpoint: Endpoint, type: T.Type) -> Future<T, Error> {
        return Future<T, Error> { [weak self] promise in
            guard let self = self else { return promise(.failure(RequestError.unknown)) }
            
            var urlComponents = URLComponents()
            urlComponents.scheme = endpoint.scheme
            urlComponents.host = endpoint.host
            urlComponents.path = endpoint.path
            
            guard let url = urlComponents.url else { return promise(.failure(RequestError.invalidURL)) }
            
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            request.allHTTPHeaderFields = endpoint.header

            if let body = endpoint.body {
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            }
            
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    guard let response = response as? HTTPURLResponse else { throw RequestError.noResponse }
                    
                    switch response.statusCode {
                    case 200...299:
                        return data
                    case 401:
                        throw RequestError.unauthorized
                    default:
                        throw RequestError.unexpectedStatusCode
                    }
                }
                .decode(type: type, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard self != nil else { return promise(.failure(RequestError.unknown)) }
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Failure with \(error.localizedDescription) error")
                        promise(.failure(error))
                    }
                }, receiveValue: { [weak self] value in
                    guard self != nil else { return promise(.failure(RequestError.unknown)) }
                    
                    promise(.success(value))
                })
                .store(in: &self.cancellables)
        }
    }
}
