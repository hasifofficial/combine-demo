//
//  UsersService.swift
//  combine-demo
//
//  Created by Mohammad Hasif Afiq on 29/05/2023.
//

protocol UsersServiceable {
    func getAllUsers() async -> Result<[User], RequestError>
    func getUserDetail(id: Int) async -> Result<User, RequestError>
}

struct UsersService: HTTPClient, UsersServiceable {
    func getAllUsers() async -> Result<[User], RequestError> {
        return await sendRequest(endpoint: UsersEndpoints.listAllUsers, responseModel: [User].self)
    }
    
    func getUserDetail(id: Int) async -> Result<User, RequestError> {
        return await sendRequest(endpoint: UsersEndpoints.userDetails(id: id), responseModel: User.self)
    }
}
