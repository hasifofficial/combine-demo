//
//  WithCombineRefactoredViewController.swift
//  combine-demo
//
//  Created by Mohammad Hasif Afiq on 28/05/2023.
//

import Foundation
import UIKit
import Combine
import SwiftUI

class WithCombineRefactoredViewModel {
    @Published private(set) var counter: Int = 0
    
    func increment() {
        counter += 1
    }
    
    func decrement() {
        counter -= 1
    }

    func reset() {
        counter = 0
    }
}

class WithCombineRefactoredViewController: UIViewController {
    private var containerStackView: UIStackView = {
        let newStackVIew = UIStackView()
        newStackVIew.axis = .vertical
        newStackVIew.alignment = .center
        newStackVIew.spacing = 16
        newStackVIew.translatesAutoresizingMaskIntoConstraints = false
        return newStackVIew
    }()
    
    private var incrementButton: UIButton = {
        let newButton = UIButton()
        newButton.setTitle("Increment", for: .normal)
        newButton.setTitleColor(.systemBlue, for: .normal)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private var decrementButton: UIButton = {
        let newButton = UIButton()
        newButton.setTitle("Decrement", for: .normal)
        newButton.setTitleColor(.systemBlue, for: .normal)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private var countLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    private var resetButton: UIButton = {
        let newButton = UIButton()
        newButton.setTitle("Reset", for: .normal)
        newButton.setTitleColor(.systemRed, for: .normal)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private var nextButton: UIButton = {
        let newButton = UIButton()
        newButton.setTitle("To API Without Combine", for: .normal)
        newButton.setTitleColor(.systemBlue, for: .normal)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    let viewModel: WithCombineRefactoredViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: WithCombineRefactoredViewModel) {
        self.viewModel = viewModel
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
        title = "With Refactored Combine"
    }

    private func setupViews() {
        view.backgroundColor = .white
                
        containerStackView.addArrangedSubview(incrementButton)
        containerStackView.addArrangedSubview(decrementButton)
        containerStackView.addArrangedSubview(countLabel)
        containerStackView.addArrangedSubview(resetButton)
        containerStackView.addArrangedSubview(nextButton)

        view.addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            containerStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    private func setupListeners() {
        incrementButton.addTarget(self, action: #selector(incrementButtonAction), for: .touchUpInside)
        decrementButton.addTarget(self, action: #selector(decrementButtonAction), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonAction), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)

        viewModel.$counter
            .map { value -> String in
                String(value)
            }
            .assign(to: \.text, on: countLabel)
            .store(in: &cancellables)
    }
    
    @objc private func nextButtonAction() {
        let userService = UserService()
        let vc = NetworkCallWithoutCombineViewController(service: userService)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func incrementButtonAction() {
        viewModel.increment()
    }
    
    @objc private func decrementButtonAction() {
        viewModel.decrement()
    }
    
    @objc private func resetButtonAction() {
        viewModel.reset()
    }
}

#if DEBUG
struct WithCombineRefactoredViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let vm = WithCombineRefactoredViewModel()
        return WithCombineRefactoredViewController(viewModel: vm)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct WithCombineRefactoredViewController_Previews: PreviewProvider {
    static var previews: some View {
        WithCombineRefactoredViewControllerRepresentable()
    }
}
#endif
