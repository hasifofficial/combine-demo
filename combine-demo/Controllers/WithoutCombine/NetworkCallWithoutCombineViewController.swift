//
//  NetworkCallWithoutCombineViewController.swift
//  combine-demo
//
//  Created by Mohammad Hasif Afiq on 28/05/2023.
//

import Foundation
import UIKit
import SwiftUI

class NetworkCallWithoutCombineViewController: UIViewController {
    private var tableView: UITableView = {
        let newTableView = UITableView(frame: .zero, style: .plain)
        newTableView.estimatedRowHeight = 100
        newTableView.translatesAutoresizingMaskIntoConstraints = false
        return newTableView
    }()
        
    private var nextButton: UIButton = {
        let newButton = UIButton()
        newButton.setTitle("To With Combine", for: .normal)
        newButton.setTitleColor(.systemBlue, for: .normal)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private var users: [User] = []
    private let service: UserService
    
    init(service: UserService) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        setupListeners()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "API Without Combine"
    }
    
    private func setupViews() {
        view.backgroundColor = .white
                
        view.addSubview(tableView)
        view.addSubview(nextButton)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -8),

            nextButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
        ])
    }
    
    private func setupListeners() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MyCustomTableViewCell.self, forCellReuseIdentifier: "cell")
        
        nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        
        loadUsers()
    }
    
    private func loadUsers() {
        service.getAllUsers {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let users):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.users = users
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadUserDetails(id: Int) {
        service.getUserDetail(id: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self,
                          let data = try? JSONEncoder().encode(user),
                          let jsonString = String(data: data, encoding: .utf8) else { return }
                    
                    let alert = UIAlertController(title: user.name, message: jsonString, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func nextButtonAction() {
        let userServiceCombine = UserServiceCombine()
        let vm = NetworkCallWithCombineViewModel(service: userServiceCombine)
        let view = NetworkCallWithCombineView(viewModel: vm)
        let vc = UIHostingController(rootView: view)
        vc.title = "API With Combine"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NetworkCallWithoutCombineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyCustomTableViewCell else { return UITableViewCell() }
        
        cell.title.text = users[indexPath.row].name
        cell.subtitle.text = users[indexPath.row].username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loadUserDetails(id: users[indexPath.row].id)
    }
}

class MyCustomTableViewCell: UITableViewCell {
    lazy var title: UILabel = {
        let newLabel = UILabel()
        newLabel.font = .systemFont(ofSize: 14)
        newLabel.textColor = .black
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    lazy var subtitle: UILabel = {
        let newLabel = UILabel()
        newLabel.font = .systemFont(ofSize: 12, weight: .light)
        newLabel.textColor = .gray
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupListener()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        selectionStyle = .none
        
        addSubview(title)
        addSubview(subtitle)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.bottomAnchor.constraint(equalTo: subtitle.topAnchor, constant: -4),

            subtitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            subtitle.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
    
    private func setupListener() {
        
    }
}
