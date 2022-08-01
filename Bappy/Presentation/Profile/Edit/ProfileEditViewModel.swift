//
//  ProfileEditViewModel.swift
//  Bappy
//
//  Created by 정동천 on 2022/07/04.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ProfileEditViewModel: ViewModelType {
    
    struct Dependency {
        let user: BappyUser
        let bappyAuthRepository: BappyAuthRepository
    }
    
    struct SubViewModels {
        let mainViewModel: ProfileEditMainViewModel
        let introduceViewModel: ProfileEditIntroduceViewModel
        let affiliationViewModel: ProfileEditAffiliationViewModel
        let languageViewModel: ProfileEditLanguageViewModel
        let personalityViewModel: ProfileEditPersonalityViewModel
        let interestsViewModel: ProfileEditInterestsViewModel
    }
    
    struct Input {
        var edittedImage: AnyObserver<UIImage?> // <-> View
        var saveButtonTapped: AnyObserver<Void> // <-> View
        var backButtonTapped: AnyObserver<Void> // <-> View
        var imageButtonTapped: AnyObserver<Void> // <-> Child(Main)
        var languageDidBeginEditing: AnyObserver<Void> // <-> Child(Language)
        var edittedAffiliation: AnyObserver<String?> // <-> Child
        var edittedIntroduce: AnyObserver<String?> // <-> Child
        var edittedLanguages: AnyObserver<[Language]?> // <-> Delegate
        var edittedPersonalities: AnyObserver<[Persnoality]?> // <-> Child
        var edittedInterests: AnyObserver<[Hangout.Category]?> // <-> Child
    }
    
    struct Output {
        var edittedImage: Signal<UIImage?> // <-> Child(Main)
        var edittedLanguages: Signal<[Language]?> // <-> Child(Language)
        var popView: Signal<Void> // <-> View
        var hideEditButton: Signal<Bool> // <-> View
        var showImagePicker: Signal<Void> // <-> View
        var showLanguageView: Signal<ProfileLanguageViewModel?> // <-> View
        var switchToMainView: Signal<BappyTabBarViewModel?> // <-> View
        var showLoader: Signal<Bool> // <-> View
    }
    
    let dependency: Dependency
    var disposeBag = DisposeBag()
    let input: Input
    let output: Output
    let subViewModels: SubViewModels
    
    private let user$: BehaviorSubject<BappyUser>
    private let currentUser$: BehaviorSubject<BappyUser?>
    private let userLanguages$: BehaviorSubject<[Language]>
    
    private let edittedImage$ = BehaviorSubject<UIImage?>(value: nil)
    private let saveButtonTapped$ = PublishSubject<Void>()
    private let backButtonTapped$ = PublishSubject<Void>()
    private let imageButtonTapped$ = PublishSubject<Void>()
    private let languageDidBeginEditing$ = PublishSubject<Void>()
    private let edittedAffiliation$ = BehaviorSubject<String?>(value: nil)
    private let edittedIntroduce$ = BehaviorSubject<String?>(value: nil)
    private let edittedLanguages$ = BehaviorSubject<[Language]?>(value: nil)
    private let edittedPersonalities$ = BehaviorSubject<[Persnoality]?>(value: nil)
    private let edittedInterests$ = BehaviorSubject<[Hangout.Category]?>(value: nil)
    
    private let showLanguageView$ = PublishSubject<ProfileLanguageViewModel?>()
    private let switchToMainView$ = PublishSubject<BappyTabBarViewModel?>()
    private let showLoader$ = PublishSubject<Bool>()
  
    init(dependency: Dependency) {
        self.dependency = dependency
        self.subViewModels = SubViewModels(
            mainViewModel: ProfileEditMainViewModel(
                dependency: .init(user: dependency.user)),
            introduceViewModel: ProfileEditIntroduceViewModel(
                dependency: .init(user: dependency.user)),
            affiliationViewModel: ProfileEditAffiliationViewModel(
                dependency: .init(user: dependency.user)),
            languageViewModel: ProfileEditLanguageViewModel(
                dependency: .init(user: dependency.user)),
            personalityViewModel: ProfileEditPersonalityViewModel(
                dependency: .init(user: dependency.user)),
            interestsViewModel: ProfileEditInterestsViewModel(
                dependency: .init(user: dependency.user))
        )
        
        // MARK: Streams
        let user$ = BehaviorSubject<BappyUser>(value: dependency.user)
        let currentUser$ = dependency.bappyAuthRepository.currentUser
        let userLanguages$ = BehaviorSubject<[Language]>(value: dependency.user.languages ?? [])
        
        let edittedImage = edittedImage$
            .asSignal(onErrorJustReturn: nil)
        let edittedLanguages = edittedLanguages$
            .asSignal(onErrorJustReturn: nil)
        let popView = backButtonTapped$
            .asSignal(onErrorJustReturn: Void())
        let hideEditButton = Observable
            .combineLatest(user$, currentUser$.compactMap { $0 })
            .map { $0.0 != $0.1 }
            .startWith(true)
            .asSignal(onErrorJustReturn: true)
        let showImagePicker = imageButtonTapped$
            .asSignal(onErrorJustReturn: Void())
        let showLanguageView = showLanguageView$
            .asSignal(onErrorJustReturn: nil)
        let switchToMainView = switchToMainView$
            .asSignal(onErrorJustReturn: nil)
        let showLoader = showLoader$
            .asSignal(onErrorJustReturn: false)
        
        // MARK: Input & Output
        self.input = Input(
            edittedImage: edittedImage$.asObserver(),
            saveButtonTapped: saveButtonTapped$.asObserver(),
            backButtonTapped: backButtonTapped$.asObserver(),
            imageButtonTapped: imageButtonTapped$.asObserver(),
            languageDidBeginEditing: languageDidBeginEditing$.asObserver(),
            edittedAffiliation: edittedAffiliation$.asObserver(),
            edittedIntroduce: edittedIntroduce$.asObserver(),
            edittedLanguages: edittedLanguages$.asObserver(),
            edittedPersonalities: edittedPersonalities$.asObserver(),
            edittedInterests: edittedInterests$.asObserver()
        )
        
        self.output = Output(
            edittedImage: edittedImage,
            edittedLanguages: edittedLanguages,
            popView: popView,
            hideEditButton: hideEditButton,
            showImagePicker: showImagePicker,
            showLanguageView: showLanguageView,
            switchToMainView: switchToMainView,
            showLoader: showLoader
        )
        
        // MARK: Bindind
        self.user$ = user$
        self.currentUser$ = currentUser$
        self.userLanguages$ = userLanguages$
        
        languageDidBeginEditing$
            .withLatestFrom(edittedLanguages$)
            .withLatestFrom(userLanguages$) { selectedLanguages, languages -> ProfileLanguageViewModel in
                let languages = selectedLanguages ?? languages
                let dependency = ProfileLanguageViewModel.Dependency(
                    userLanguages: languages)
                let viewModel = ProfileLanguageViewModel(dependency: dependency)
                viewModel.delegate = self
                return viewModel
            }
            .bind(to: showLanguageView$)
            .disposed(by: disposeBag)
        
        let edittingResult = saveButtonTapped$
            .withLatestFrom(Observable.combineLatest(
                edittedAffiliation$,
                edittedIntroduce$,
                edittedLanguages$,
                edittedPersonalities$,
                edittedInterests$,
                edittedImage$
            ))
            .filter { $0.0 != nil || $0.1 != nil || $0.2 != nil || $0.3 != nil || $0.4 != nil || $0.5 != nil }
            .do { [weak self] _ in self?.showLoader$.onNext(true) }
            .flatMap(dependency.bappyAuthRepository.updateProfile)
            .observe(on: MainScheduler.asyncInstance)
            .share()
        
        edittingResult
            .compactMap(getEdittingError)
            .do { [weak self] _ in self?.showLoader$.onNext(false) }
            .bind(onNext: { print("ERROR: \($0)") })
            .disposed(by: disposeBag)
        
        let userResult = edittingResult
            .compactMap(getEditting)
            .map { _ in }
            .flatMap(dependency.bappyAuthRepository.fetchCurrentUser)
            .do { [weak self] _ in self?.showLoader$.onNext(false) }
            .observe(on: MainScheduler.asyncInstance)
            .share()
        
        userResult
            .compactMap(getUserError)
            .bind(onNext: { print("ERROR: \($0)") })
            .disposed(by: disposeBag)
        
        userResult
            .compactMap(getUser)
            .map { user -> BappyTabBarViewModel in
                let dependecy = BappyTabBarViewModel.Dependency(
                    selectedIndex: 1,
                    user: user,
                    bappyAuthRepository: dependency.bappyAuthRepository)
                return BappyTabBarViewModel(dependency: dependecy)
            }
            .bind(to: switchToMainView$)
            .disposed(by: disposeBag)
        
        // Child(Main)
        edittedImage
            .emit(to: subViewModels.mainViewModel.input.edittedImage)
            .disposed(by: disposeBag)
            
        
        subViewModels.mainViewModel.output.imageButtonTapped
            .emit(to: imageButtonTapped$)
            .disposed(by: disposeBag)
        
        // Child(Introduce)
        subViewModels.introduceViewModel.output.edittedIntroduce
            .emit(to: input.edittedIntroduce)
            .disposed(by: disposeBag)
        
        // Child(affiliation)
        subViewModels.affiliationViewModel.output.edittedAffiliation
            .emit(to: input.edittedAffiliation)
            .disposed(by: disposeBag)
        
        // Child(Language)
        edittedLanguages$
            .bind(to: subViewModels.languageViewModel.input.selectedLanguages)
            .disposed(by: disposeBag)
        
        subViewModels.languageViewModel.output.didBeginEditing
            .emit(to: languageDidBeginEditing$)
            .disposed(by: disposeBag)
        
        // Child(Personality)
        subViewModels.personalityViewModel.output.edittedPersonalities
            .emit(to: input.edittedPersonalities)
            .disposed(by: disposeBag)
        
        // Child(Interest)
        subViewModels.interestsViewModel.output.edittedInterests
            .emit(to: input.edittedInterests)
            .disposed(by: disposeBag)
    }
}

private func getEditting(_ result: Result<Bool, Error>) -> Bool? {
    guard case .success(let value) = result else { return nil }
    return value
}

private func getEdittingError(_ result: Result<Bool, Error>) -> String? {
    guard case .failure(let error) = result else { return nil }
    return error.localizedDescription
}

private func getUser(_ result: Result<BappyUser, Error>) -> BappyUser? {
    guard case .success(let value) = result else { return nil }
    return value
}

private func getUserError(_ result: Result<BappyUser, Error>) -> String? {
    guard case .failure(let error) = result else { return nil }
    return error.localizedDescription
}

// MARK: - ProfileLanguageViewModelDelegate
extension ProfileEditViewModel: ProfileLanguageViewModelDelegate {
    func selectedLanguages(_ languages: [Language]) {
        input.edittedLanguages.onNext(languages)
    }
}
