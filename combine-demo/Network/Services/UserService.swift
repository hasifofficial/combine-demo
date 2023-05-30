//
//  UsersService.swift
//  combine-demo
//
//  Created by Mohammad Hasif Afiq on 29/05/2023.
//

import Combine

protocol UserServiceable {
    func getAllUsers(completion: @escaping ((Result<[User], Error>) -> Void))
    func getUserDetail(id: Int, completion: @escaping ((Result<User, Error>) -> Void))
}

protocol UserServiceableCombine {
    func getAllUsers() -> Future<[User], Error>
    func getUserDetail(id: Int) -> Future<User, Error>
}

struct UserService: UserServiceable {
    func getAllUsers(completion: @escaping ((Result<[User], Error>) -> Void)) {
        API.shared.request(
            endpoint: UsersEndpoints.listAllUsers,
            type: [User].self,
            completion: completion
        )
    }
    
    func getUserDetail(id: Int, completion: @escaping ((Result<User, Error>) -> Void)) {
        API.shared.request(
            endpoint: UsersEndpoints.userDetails(id: id),
            type: User.self,
            completion: completion
        )
    }
}

struct UserServiceCombine: UserServiceableCombine {
    func getAllUsers() -> Future<[User], Error> {
        API.shared.request(
            endpoint: UsersEndpoints.listAllUsers,
            type: [User].self
        )
    }
    
    func getUserDetail(id: Int) -> Future<User, Error> {
        API.shared.request(
            endpoint: UsersEndpoints.userDetails(id: id),
            type: User.self
        )
    }
}
