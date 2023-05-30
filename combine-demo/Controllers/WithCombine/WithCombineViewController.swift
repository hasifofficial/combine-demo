//
//  WithCombineViewController.swift
//  combine-demo
//
//  Created by Mohammad Hasif Afiq on 28/05/2023.
//

import Foundation
import UIKit
import Combine
import SwiftUI

class WithCombineViewController: UIViewController {
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
        newButton.setTitle("To Refactored Combine", for: .normal)
        newButton.setTitleColor(.systemBlue, for: .normal)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private var counter = CurrentValueSubject<Int, Never>(0)
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        setupListeners()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "With Combine"
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

        counter
            .receive(on: DispatchQueue.main)
            .map { value -> String in
                String(value)
            }
            .assign(to: \.text, on: countLabel)
        // Another way to bind/subscribe
//            .sink { [weak self] value in
//                guard let self = self else { return }
//                self.countLabel.text = value
//            }
            .store(in: &cancellables)
    }
    
    @objc private func nextButtonAction() {
        let vm = WithCombineRefactoredViewModel()
        let vc = WithCombineRefactoredViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func incrementButtonAction() {
        counter.send(counter.value + 1)
    }
    
    @objc private func decrementButtonAction() {
        counter.send(counter.value - 1)
    }
    
    @objc private func resetButtonAction() {
        counter.send(0)
    }
}

#if DEBUG
struct WithCombineViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return WithCombineViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct WithCombineViewController_Previews: PreviewProvider {
    static var previews: some View {
        WithCombineViewControllerRepresentable()
    }
}
#endif
