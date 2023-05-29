//
//  UsersEndpoints.swift
//  combine-demo
//
//  Created by Mohammad Hasif Afiq on 29/05/2023.
//

enum UsersEndpoints {
    case listAllUsers
    case userDetails(id: Int)
}

extension UsersEndpoints: Endpoint {
    var path: String {
        switch self {
        case .listAllUsers:
            return "/users"
        case .userDetails(let id):
            return "/users/\(id)"
        }
    }

    var method: RequestMethod {
        switch self {
        case .listAllUsers, .userDetails:
            return .get
        }
    }
    
    var header: [String: String]? {
        switch self {
        case .listAllUsers, .userDetails:
            return nil
        }
    }
    
    var body: [String: String]? {
        switch self {
        case .listAllUsers, .userDetails:
            return nil
        }
    }
}
