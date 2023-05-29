//
//  WithRxViewController.swift
//  combine-demo
//
//  Created by Mohammad Hasif Afiq on 28/05/2023.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class WithRxViewController: UIViewController {
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
        newButton.setTitleColor(.systemBlue, for: .normal)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private var nextButton: UIButton = {
        let newButton = UIButton()
        newButton.setTitle("To With Combine", for: .normal)
        newButton.setTitleColor(.systemBlue, for: .normal)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private var counter = BehaviorRelay<Int>(value: 0)
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        setupListeners()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "With Rx"
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
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.countLabel.text = String(value)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func nextButtonAction() {
        let vc = WithCombineViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func incrementButtonAction() {
        counter.accept(counter.value + 1)
    }
    
    @objc private func decrementButtonAction() {
        counter.accept(counter.value - 1)
    }
    
    @objc private func resetButtonAction() {
        counter.accept(0)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct WithRxViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return WithRxViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
#endif

struct WithRxViewController_Previews: PreviewProvider {
    static var previews: some View {
        WithRxViewControllerRepresentable()
    }
}
