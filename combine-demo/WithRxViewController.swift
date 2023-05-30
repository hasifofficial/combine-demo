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

class WithRxViewModel {
    struct Input {
        let didTapIncrement: Signal<Void>
        let didTapDecrement: Signal<Void>
        let didTapReset: Signal<Void>
        let didTapNext: Signal<Void>
    }
    
    struct Output {
        let didTapIncrementSignal: Signal<Void>
        let didTapDecrementSignal: Signal<Void>
        let didTapResetSignal: Signal<Void>
        let didTapNextSignal: Signal<Void>
        let counterSignal: Signal<Int>
    }
    
    private let counterRelay = BehaviorRelay<Int>(value: 0)
    
    func transform(input: Input) -> Output {
        let didTapIncrementSignal = input.didTapIncrement.do(onNext: { [weak self] in
            guard let self = self else { return }
            self.counterRelay.accept(self.counterRelay.value + 1)
        })
        
        let didTapDecrementSignal = input.didTapDecrement.do(onNext: { [weak self] in
            guard let self = self else { return }
            self.counterRelay.accept(self.counterRelay.value - 1)
        })
        
        let didTapResetSignal = input.didTapReset.do(onNext: { [weak self] in
            guard let self = self else { return }
            self.counterRelay.accept(0)
        })

        return Output(
            didTapIncrementSignal: didTapIncrementSignal,
            didTapDecrementSignal: didTapDecrementSignal,
            didTapResetSignal: didTapResetSignal,
            didTapNextSignal: input.didTapNext.asSignal(),
            counterSignal: counterRelay.asSignal(onErrorJustReturn: 0)
        )
    }
}

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
        newButton.setTitleColor(.systemRed, for: .normal)
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
    
    let viewModel: WithRxViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: WithRxViewModel) {
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
        let output = viewModel.transform(input: .init(
            didTapIncrement: incrementButton.rx.tap.asSignal(),
            didTapDecrement: decrementButton.rx.tap.asSignal(),
            didTapReset: resetButton.rx.tap.asSignal(),
            didTapNext: nextButton.rx.tap.asSignal()
        ))
        
        output.didTapIncrementSignal
            .emit()
            .disposed(by: disposeBag)
        
        output.didTapDecrementSignal
            .emit()
            .disposed(by: disposeBag)

        output.didTapResetSignal
            .emit()
            .disposed(by: disposeBag)

        output.didTapNextSignal
            .emit(onNext: { [weak self] value in
                guard let self = self else { return }
                let vc = WithCombineViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)

        output.counterSignal
            .emit(onNext: { [weak self] value in
                guard let self = self else { return }
                self.countLabel.text = String(value)
            })
            .disposed(by: disposeBag)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct WithRxViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let vm = WithRxViewModel()
        return WithRxViewController(viewModel: vm)
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
