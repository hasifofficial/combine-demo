//
//  NetworkCallWithCombineView.swift
//  combine-demo
//
//  Created by Mohammad Hasif Afiq on 29/05/2023.
//

import SwiftUI
import Combine

class NetworkCallWithCombineViewModel: ObservableObject {
    @Published var users: [User] = []
    private let service: UsersService
    
    init(service: UsersService) {
        self.service = service
    }

    func loadUsers() {
        fetchData { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }

                    self.users = response
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchData(completion: @escaping (Result<[User], RequestError>) -> Void) {
        Task(priority: .background) { [weak self] in
            guard let self = self else { return }
            
            let result = await self.service.getAllUsers()
            completion(result)
        }
    }
}

struct NetworkCallWithCombineView: View {
    @ObservedObject var viewModel: NetworkCallWithCombineViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.users) { user in
                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    Text(user.username)
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.gray)
                }
           }
        }
        .listStyle(.grouped)
        .onAppear {
            viewModel.loadUsers()
        }
    }
}

struct NetworkCallWithCombineView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkCallWithCombineView(viewModel: NetworkCallWithCombineViewModel(service: UsersService()))
    }
}
