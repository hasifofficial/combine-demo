//
//  HTTPClient.swift
//  combine-demo
//
//  Created by Mohammad Hasif Afiq on 29/05/2023.
//

import Foundation
import Combine

protocol HTTPClient {
    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async -> Result<T, RequestError>
}

extension HTTPClient {
    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async -> Result<T, RequestError> {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path
        
        guard let url = urlComponents.url else { return .failure(.invalidURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header

        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else { return .failure(.noResponse) }
            
            switch response.statusCode {
            case 200...299:
                guard let decodedResponse = try? JSONDecoder().decode(responseModel, from: data) else { return .failure(.decode) }
                return .success(decodedResponse)
            case 401:
                return .failure(.unauthorized)
            default:
                return .failure(.unexpectedStatusCode)
            }
        } catch {
            return .failure(.unknown)
        }
    }
}

//class API {
//    private var cancellables = Set<AnyCancellable>()
//    
//    func getData<T: Decodable>(endpoint: Endpoint, type: T.Type, completion: @escaping ((Result<T, RequestError>) -> Void)) {
//        var urlComponents = URLComponents()
//        urlComponents.scheme = endpoint.scheme
//        urlComponents.host = endpoint.host
//        urlComponents.path = endpoint.path
//        
//        guard let url = urlComponents.url else { return }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = endpoint.method.rawValue
//        request.allHTTPHeaderFields = endpoint.header
//
//        if let body = endpoint.body {
//            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
//        }
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let response = response as? HTTPURLResponse else { return .failure(.noResponse) }
//            
//            switch response.statusCode {
//            case 200...299:
//                guard let decodedResponse = try? JSONDecoder().decode(type, from: data) else { return .failure(.decode) }
//                return .success(decodedResponse)
//            case 401:
//                return .failure(.unauthorized)
//            default:
//                return .failure(.unexpectedStatusCode)
//            }
//
//        }
//
//    }
//
//    func getData<T: Decodable>(endpoint: Endpoint, type: T.Type) -> Future<T, RequestError> {
//        return Future<T, RequestError> { [weak self] promise in
//            guard let self = self else { return promise(.failure(.unknown)) }
//            
//            var urlComponents = URLComponents()
//            urlComponents.scheme = endpoint.scheme
//            urlComponents.host = endpoint.host
//            urlComponents.path = endpoint.path
//            
//            guard let url = urlComponents.url else { return promise(.failure(.invalidURL)) }
//            
//            URLSession.shared.dataTaskPublisher(for: url)
//                .tryMap { (data, response) -> Data in
//                    guard let response = response as? HTTPURLResponse else { throw RequestError.noResponse }
//                    
//                    switch response.statusCode {
//                    case 200...299:
//                        return data
//                    case 401:
//                        throw RequestError.unauthorized
//                    default:
//                        throw RequestError.unexpectedStatusCode
//                    }
//                }
//                .decode(type: type, decoder: JSONDecoder())
//                .receive(on: RunLoop.main)
//                .sink(receiveCompletion: { (completion) in
//                    if case let .failure(error) = completion {
//                        switch error {
//                        case let decodingError as DecodingError:
//                            promise(.failure(.decode))
////                        case let apiError as NetworkError:
////                            promise(.failure(apiError))
//                        default:
//                            promise(.failure(.unknown))
//                        }
//                    }
//                }, receiveValue: { [weak self] value in
//                    guard let self = self else { return promise(.failure(.unknown)) }
//                    promise(.success(value))
//                })
//                .store(in: &self.cancellables)
//        }
//    }
//}
