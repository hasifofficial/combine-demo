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
    @Published var userDetails: User? = nil

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
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] users in
                guard let self = self else { return }
                self.users = users
            }
            .store(in: &cancellable)
    }
    
    func loadUserDetails(id: Int?) {
        guard let id = id else { return }
        
        service.getUserDetail(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard self != nil else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] userDetails in
                guard let self = self else { return }
                self.userDetails = userDetails
            }
            .store(in: &cancellable)
    }
    
    func userDetailToJsonString() -> String {
        guard let data = try? JSONEncoder().encode(userDetails),
              let jsonString = String(data: data, encoding: .utf8) else { return "" }

        return jsonString
    }
}

struct NetworkCallWithCombineView: View {
    @ObservedObject var viewModel: NetworkCallWithCombineViewModel
    @State private var presentAlert: Bool = false
        
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
                }.onTapGesture {
                    viewModel.loadUserDetails(id: user.id)
                    
                    if viewModel.userDetails != nil {
                        presentAlert.toggle()
                    }
                }
           }
        }
        .alert(isPresented: $presentAlert) {
            Alert(
                title: Text(viewModel.userDetails?.name ?? ""),
                message: Text(viewModel.userDetailToJsonString())
            )
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
