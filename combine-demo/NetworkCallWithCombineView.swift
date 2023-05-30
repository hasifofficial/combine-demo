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
    
    private let service: UserServiceCombine
    private var cancellable = Set<AnyCancellable>()

    init(service: UserServiceCombine) {
        self.service = service
    }

    func loadUsers() {
        service.getAllUsers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard self != nil else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("error: \(error)")
                }
            } receiveValue: { [weak self] users in
                guard let self = self else { return }
                self.users = users
            }
            .store(in: &cancellable)
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
        NetworkCallWithCombineView(viewModel: NetworkCallWithCombineViewModel(service: UserServiceCombine()))
    }
}
