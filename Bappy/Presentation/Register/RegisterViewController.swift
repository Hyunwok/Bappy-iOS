//
//  RegisterNameViewController.swift
//  Bappy
//
//  Created by 정동천 on 2022/05/10.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class RegisterViewController: UIViewController {
    
    // MARK: Properties
    private let viewModel: RegisterViewModel
    private let disposeBag = DisposeBag()
    private let backButton = UIButton()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let progressBarView = ProgressBarView()
    private let continueButtonView: ContinueButtonView
    private let nameView: RegisterNameView
    private let genderView: RegisterGenderView
    private let birthView: RegisterBirthView
    private let nationalityView: RegisterNationalityView
    
    // MARK: Lifecycle
    init(viewModel: RegisterViewModel) {
        let nameViewModel = viewModel.subViewModels.nameViewModel
        let genderViewModel = viewModel.subViewModels.genderViewModel
        let birthViewModel = viewModel.subViewModels.birthViewModel
        let nationalityViewModel = viewModel.subViewModels.nationalityViewModel
        let continueButtonViewModel = viewModel.subViewModels.continueButtonViewModel
        
        self.viewModel = viewModel
        self.nameView = RegisterNameView(viewModel: nameViewModel)
        self.genderView = RegisterGenderView(viewModel: genderViewModel)
        self.birthView = RegisterBirthView(viewModel: birthViewModel)
        self.nationalityView = RegisterNationalityView(viewModel: nationalityViewModel)
        self.continueButtonView = ContinueButtonView(viewModel: continueButtonViewModel)
        
        super.init(nibName: nil, bundle: nil)
        
        configure()
        layout()
        bind()
        addTapGestureOnScrollView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        view.endEditing(true)
    }
    
    @objc
    private func touchesScrollView() {
        view.endEditing(true)
    }
    
    // MARK: Helpers
    private func updateButtonPostion(keyboardHeight: CGFloat) {
        let bottomPadding = (keyboardHeight != 0) ? view.safeAreaInsets.bottom : view.safeAreaInsets.bottom * 2.0 / 3.0

        UIView.animate(withDuration: 0.4) {
            self.continueButtonView.snp.updateConstraints {
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(bottomPadding - keyboardHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func addTapGestureOnScrollView() {
        let scrollViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchesScrollView))
        scrollView.addGestureRecognizer(scrollViewTapRecognizer)
    }

    private func configure() {
        view.backgroundColor = .white
        backButton.setImage(UIImage(named: "chevron_back"), for: .normal)
        backButton.imageEdgeInsets = .init(top: 13.0, left: 16.5, bottom: 13.0, right: 16.5)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
    }
    
    private func layout() {
        view.addSubview(progressBarView)
        progressBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.top.equalTo(progressBarView.snp.bottom).offset(15.0)
            $0.leading.equalToSuperview().inset(5.5)
            $0.width.height.equalTo(44.0)
        }

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        view.addSubview(nameView)
        nameView.snp.makeConstraints {
            $0.top.leading.bottom.equalTo(contentView)
            $0.width.equalTo(view.frame.width)
        }
        
        view.addSubview(genderView)
        genderView.snp.makeConstraints {
            $0.top.bottom.equalTo(contentView)
            $0.width.equalTo(view.frame.width)
            $0.leading.equalTo(nameView.snp.trailing)
        }
        
        view.addSubview(birthView)
        birthView.snp.makeConstraints {
            $0.top.bottom.equalTo(contentView)
            $0.width.equalTo(view.frame.width)
            $0.leading.equalTo(genderView.snp.trailing)
        }
        
        view.addSubview(nationalityView)
        nationalityView.snp.makeConstraints {
            $0.top.bottom.trailing.equalTo(contentView)
            $0.width.equalTo(view.frame.width)
            $0.leading.equalTo(birthView.snp.trailing)
        }
        
        view.addSubview(continueButtonView)
        continueButtonView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(bottomPadding * 2.0 / 3.0)
        }
    }
}

// MARK: - Bind
extension RegisterViewController {
    private func bind() {
        backButton.rx.tap
            .bind(to: viewModel.input.backButtonTapped)
            .disposed(by: disposeBag)
        
        self.rx.viewDidAppear
            .bind(to: viewModel.input.viewDidAppear)
            .disposed(by: disposeBag)
        
        viewModel.output.shouldKeyboardHide
            .emit(to: view.rx.endEditing)
            .disposed(by: disposeBag)
        
        viewModel.output.pageContentOffset
            .drive(scrollView.rx.setContentOffset)
            .disposed(by: disposeBag)

        viewModel.output.progression
            .skip(1)
            .drive(progressBarView.rx.setProgression)
            .disposed(by: disposeBag)
        
        viewModel.output.initProgression
            .emit(to: progressBarView.rx.initProgression)
            .disposed(by: disposeBag)
        
        viewModel.output.popView
            .emit(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.showSelectNationalityView
            .compactMap { $0 }
            .emit(onNext: { [weak self] viewModel in
                let viewController = SelectNationalityViewController(viewModel: viewModel)
                viewController.modalPresentationStyle = .overCurrentContext
                self?.present(viewController, animated: false, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.showCompleteView
            .compactMap { $0 }
            .emit(onNext: { [weak self] viewModel in
                let viewController = RegisterCompletedViewController(viewModel: viewModel)
                viewController.modalPresentationStyle = .overCurrentContext
                self?.present(viewController, animated: false, completion: nil)
            })
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { [weak self] height in
                self?.updateButtonPostion(keyboardHeight: height)
            })
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .map { [weak self] height in
                return height + (self?.continueButtonView.frame.height ?? 0)
            }
            .drive(viewModel.input.keyboardWithButtonHeight)
            .disposed(by: disposeBag)
    }
}
