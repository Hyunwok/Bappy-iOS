//
//  HangoutMakeViewModel.swift
//  Bappy
//
//  Created by 정동천 on 2022/06/15.
//

import UIKit
import RxSwift
import RxCocoa

final class HangoutMakeViewModel: ViewModelType {
    
    struct SubViewModels {
        let categoryViewModel: HangoutMakeCategoryViewModel
        let titleViewModel: HangoutMakeTitleViewModel
        let timeViewModel: HangoutMakeTimeViewModel
        let placeViewModel: HangoutMakePlaceViewModel
        let pictureViewModel: HangoutMakePictureViewModel
        let planViewModel: HangoutMakePlanViewModel
        let languageViewModel: HangoutMakeLanguageViewModel
        let openchatViewModel: HangoutMakeOpenchatViewModel
        let limitViewModel: HangoutMakeLimitViewModel
        let continueButtonViewModel: ContinueButtonViewModel
    }
    
    struct Dependency {
        var currentUser: User
        var numOfPage: Int
        var key: String
        var categoryDependency: HangoutMakeCategoryViewModel.Dependency
        var titleDependency: HangoutMakeTitleViewModel.Dependency
        var timeDependency: HangoutMakeTimeViewModel.Dependency
        var placeDependency: HangoutMakePlaceViewModel.Dependency
        var pictureDependency: HangoutMakePictureViewModel.Dependency
        var planDependency: HangoutMakePlanViewModel.Dependency
        var languageDependency: HangoutMakeLanguageViewModel.Dependency
        var openchatDependency: HangoutMakeOpenchatViewModel.Dependency
        var limitDependency: HangoutMakeLimitViewModel.Dependency
        var searchPlaceDependency: SearchPlaceViewModel.Dependency
        var selectLanguageDependecy: SelectLanguageViewModel.Dependency
    }
    
    struct Input {
        var continueButtonTapped: AnyObserver<Void>
        var backButtonTapped: AnyObserver<Void>
        var viewDidAppear: AnyObserver<Bool>
        var keyboardWithButtonHeight: AnyObserver<CGFloat>
        var categories: AnyObserver<[HangoutCategory]?>
        var title: AnyObserver<String?>
        var date: AnyObserver<Date?>
        var place: AnyObserver<Map?>
        var picture: AnyObserver<UIImage?>
        var plan: AnyObserver<String?>
        var language: AnyObserver<Language?>
        var openchat: AnyObserver<String?>
        var limit: AnyObserver<Int?>
        var isCategoriesValid: AnyObserver<Bool>
        var isTitleValid: AnyObserver<Bool>
        var isTimeValid: AnyObserver<Bool>
        var isPlaceValid: AnyObserver<Bool>
        var isPictureValid: AnyObserver<Bool>
        var isPlanValid: AnyObserver<Bool>
        var isLanguageValid: AnyObserver<Bool>
        var isOpenchatValid: AnyObserver<Bool>
        var isLimitValid: AnyObserver<Bool>
        var showSearchPlaceView: AnyObserver<SearchPlaceViewModel>
        var showSelectLanguageView: AnyObserver<SelectLanguageViewModel>
    }
    
    struct Output {
        var shouldKeyboardHide: Signal<Void>
        var pageContentOffset: Driver<CGPoint>
        var progression: Driver<CGFloat>
        var initProgression: Signal<CGFloat>
        var popView: Signal<Void>
        var isContinueButtonEnabled: Signal<Bool>
        var keyboardWithButtonHeight: Signal<CGFloat>
        var showSearchPlaceView: Signal<SearchPlaceViewModel>
        var showImagePicker: Signal<Void>
        var showSelectLanguageView: Signal<SelectLanguageViewModel>
        var showLoader: Signal<Void>
        var dismissLoader: Signal<Void>
        var showHangoutPreview: Observable<HangoutDetailViewModel>
    }
    
    let dependency: Dependency
    var disposeBag = DisposeBag()
    let input: Input
    let output: Output
    let subViewModels: SubViewModels
    let repository: GoogleMapImageRepository
    
    private let page$ = BehaviorSubject<Int>(value: 0)
    private let currentUser$: BehaviorSubject<User>
    private let numOfPage$: BehaviorSubject<Int>
    private let key$: BehaviorSubject<String>
    private let continueButtonTapped$ = PublishSubject<Void>()
    private let backButtonTapped$ = PublishSubject<Void>()
    private let viewDidAppear$ = PublishSubject<Bool>()
    private let keyboardWithButtonHeight$ = PublishSubject<CGFloat>()
    private let categories$ = BehaviorSubject<[HangoutCategory]?>(value: [])
    private let title$ = BehaviorSubject<String?>(value: nil)
    private let date$ = BehaviorSubject<Date?>(value: nil)
    private let place$ = BehaviorSubject<Map?>(value: nil)
    private let picture$ = BehaviorSubject<UIImage?>(value: nil)
    private let plan$ = BehaviorSubject<String?>(value: nil)
    private let language$ = BehaviorSubject<Language?>(value: nil)
    private let openchat$ = BehaviorSubject<String?>(value: nil)
    private let limit$ = BehaviorSubject<Int?>(value: nil)
    private let isCategoriesValid$ = BehaviorSubject<Bool>(value: false)
    private let isTitleValid$ = BehaviorSubject<Bool>(value: false)
    private let isTimeValid$ = BehaviorSubject<Bool>(value: false)
    private let isPlaceValid$ = BehaviorSubject<Bool>(value: false)
    private let isPictureValid$ = BehaviorSubject<Bool>(value: false)
    private let isPlanValid$ = BehaviorSubject<Bool>(value: false)
    private let isLanguageValid$ = BehaviorSubject<Bool>(value: false)
    private let isOpenchatValid$ = BehaviorSubject<Bool>(value: false)
    private let isLimitValid$ = BehaviorSubject<Bool>(value: true)
    private let showSearchPlaceView$ = PublishSubject<SearchPlaceViewModel>()
    private let showImagePicker$ = PublishSubject<Void>()
    private let showSelectLanguageView$ = PublishSubject<SelectLanguageViewModel>()
    private let showLoader$ = PublishSubject<Void>()
    private let dismissLoader$ = PublishSubject<Void>()
    
    init(dependency: Dependency) {
        self.dependency = dependency
        self.subViewModels = SubViewModels(
            categoryViewModel: HangoutMakeCategoryViewModel(dependency: dependency.categoryDependency),
            titleViewModel: HangoutMakeTitleViewModel(dependency: dependency.titleDependency),
            timeViewModel: HangoutMakeTimeViewModel(dependency: dependency.timeDependency),
            placeViewModel: HangoutMakePlaceViewModel(dependency: dependency.placeDependency),
            pictureViewModel: HangoutMakePictureViewModel(dependency: dependency.pictureDependency),
            planViewModel: HangoutMakePlanViewModel(dependency: dependency.planDependency),
            languageViewModel: HangoutMakeLanguageViewModel(dependency: dependency.languageDependency),
            openchatViewModel: HangoutMakeOpenchatViewModel(dependency: dependency.openchatDependency),
            limitViewModel: HangoutMakeLimitViewModel(dependency: dependency.limitDependency),
            continueButtonViewModel: ContinueButtonViewModel()
        )
        self.repository = DefaultGoogleMapImageRepository()
        
        // Streams
        let currentUser$ = BehaviorSubject<User>(value: dependency.currentUser)
        let numOfPage$ = BehaviorSubject<Int>(value: dependency.numOfPage)
        let key$ = BehaviorSubject<String>(value: dependency.key)
        
        let shouldKeyboardHide = Observable
            .merge(continueButtonTapped$, backButtonTapped$)
            .asSignal(onErrorJustReturn: Void())
        let pageContentOffset = page$.map(getContentOffset)
            .asDriver(onErrorJustReturn: .zero)
        let progression = page$.withLatestFrom(numOfPage$.filter { $0 != 0 },
                                                resultSelector: getProgression)
            .asDriver(onErrorJustReturn: .zero)
        let initProgression = viewDidAppear$
            .withLatestFrom(progression)
            .asSignal(onErrorJustReturn: 0)
        let backButtonTappedWithPage = backButtonTapped$
            .withLatestFrom(page$)
            .share()
        let popView = backButtonTappedWithPage
            .filter { $0 == 0 }
            .map { _ in }
            .asSignal(onErrorJustReturn: Void())
        
        let continueButtonTappedWithPage = continueButtonTapped$
            .withLatestFrom(Observable.combineLatest(page$, numOfPage$))
            .share()
        let isContinueButtonEnabled = Observable
            .merge(
                Observable.combineLatest(
                    page$.filter { $0 >= 0 && $0 <= 4 },
                    isCategoriesValid$, isTitleValid$, isTimeValid$, isPlaceValid$, isPictureValid$,
                    resultSelector: shouldButtonEnabledWithFirst
                ),
                Observable.combineLatest(
                    page$.filter { $0 >= 5 && $0 <= 8 },
                    isPlanValid$, isLanguageValid$, isOpenchatValid$, isLimitValid$,
                    resultSelector: shouldButtonEnabledWithSecond
                )
            )
            .distinctUntilChanged()
            .asSignal(onErrorJustReturn: false)
        let keyboardWithButtonHeight = keyboardWithButtonHeight$
            .asSignal(onErrorJustReturn: 0)
        let showSearchPlaceView = showSearchPlaceView$
            .asSignal(onErrorJustReturn: SearchPlaceViewModel(dependency: dependency.searchPlaceDependency))
        let showImagePicker = showImagePicker$
            .asSignal(onErrorJustReturn: Void())
        let showSelectLanguageView = showSelectLanguageView$
            .asSignal(onErrorJustReturn: SelectLanguageViewModel(dependency: dependency.selectLanguageDependecy))
        let showLoader = showLoader$
            .asSignal(onErrorJustReturn: Void())
        let dismissLoader = dismissLoader$
            .asSignal(onErrorJustReturn: Void())
        let hangout = Observable
            .combineLatest(
                Observable.combineLatest(
                    categories$.compactMap { $0 }.debug("categories"),
                    title$.compactMap { $0 }.debug("title"),
                    date$.compactMap { $0 }.debug("date"),
                    place$.compactMap { $0 }.debug("place"),
                    picture$.compactMap { $0 }.debug("picture")
                ),
                Observable.combineLatest(
                    plan$.compactMap { $0 }.debug("plan"),
                    language$.compactMap { $0 }.debug("language"),
                    openchat$.compactMap { $0 }.debug("openchat"),
                    limit$.compactMap { $0 }.debug("limit")
                )
            )
            .map {
                Hangout(
                    id: "preview", state: .preview, title: $0.1,
                    meetTime: $0.2.toString(dateFormat: "dd. MMM. HH:mm"), language: $1.1, placeID: $0.3.id, placeName: $0.3.name, plan: $1.0, limitNumber: $1.3, coordinates: $0.3.coordinates, postImageURL: nil, openchatURL: URL(string: $1.2), mapImageURL: nil, participantIDs: [.init(id: dependency.currentUser.id, imageURL: dependency.currentUser.profileImageURL)], userHasLiked: false)
            }
            .share()
        
        let result = continueButtonTapped$
            .withLatestFrom(Observable.combineLatest(page$, numOfPage$))
            .filter { $0.0 + 1 == $0.1 }
            .withLatestFrom(
                Observable.combineLatest(key$, place$.compactMap { $0 })
            ) { ($1.0, $1.1.coordinates.latitude, $1.1.coordinates.longitude) }
            .map(repository.fetchMapImage)
            .flatMap { $0 }
            .share()
        
        let value = result
            .compactMap(getValue)
            .share()
        
        let error = result
            .compactMap(getError)
        
        error
            .bind(onNext: { print("ERROR: \($0)")})
            .disposed(by: disposeBag)
        
        let showHangoutPreview = value
            .withLatestFrom(Observable.combineLatest(
                currentUser$, hangout, picture$.compactMap { $0 }
            )) { ($1.0, $1.1, $1.2, $0) }
            .map(getHangoutDetailViewModel)
        
        // Input & Output
        self.input = Input(
            continueButtonTapped: continueButtonTapped$.asObserver(),
            backButtonTapped: backButtonTapped$.asObserver(),
            viewDidAppear: viewDidAppear$.asObserver(),
            keyboardWithButtonHeight: keyboardWithButtonHeight$.asObserver(),
            categories: categories$.asObserver(),
            title: title$.asObserver(),
            date: date$.asObserver(),
            place: place$.asObserver(),
            picture: picture$.asObserver(),
            plan: plan$.asObserver(),
            language: language$.asObserver(),
            openchat: openchat$.asObserver(),
            limit: limit$.asObserver(),
            isCategoriesValid: isCategoriesValid$.asObserver(),
            isTitleValid: isTitleValid$.asObserver(),
            isTimeValid: isTimeValid$.asObserver(),
            isPlaceValid: isPlaceValid$.asObserver(),
            isPictureValid: isPictureValid$.asObserver(),
            isPlanValid: isPlanValid$.asObserver(),
            isLanguageValid: isLanguageValid$.asObserver(),
            isOpenchatValid: isOpenchatValid$.asObserver(),
            isLimitValid: isLimitValid$.asObserver(),
            showSearchPlaceView: showSearchPlaceView$.asObserver(),
            showSelectLanguageView: showSelectLanguageView$.asObserver()
        )
        
        self.output = Output(
            shouldKeyboardHide: shouldKeyboardHide,
            pageContentOffset: pageContentOffset,
            progression: progression,
            initProgression: initProgression,
            popView: popView,
            isContinueButtonEnabled: isContinueButtonEnabled,
            keyboardWithButtonHeight: keyboardWithButtonHeight,
            showSearchPlaceView: showSearchPlaceView,
            showImagePicker: showImagePicker,
            showSelectLanguageView: showSelectLanguageView,
            showLoader: showLoader,
            dismissLoader: dismissLoader,
            showHangoutPreview: showHangoutPreview
        )
        
        // Bindind
        self.currentUser$ = currentUser$
        self.numOfPage$ = numOfPage$
        self.key$ = key$
        
        continueButtonTappedWithPage
            .filter { $0.0 + 1 < $0.1 }
            .map { $0.0 + 1 }
            .bind(to: page$)
            .disposed(by: disposeBag)
        
        backButtonTappedWithPage
            .filter { $0 > 0 }
            .map { $0 - 1 }
            .bind(to: page$)
            .disposed(by: disposeBag)
        
        // Child(Category)
        subViewModels.categoryViewModel.output.categories
            .emit(to: categories$)
            .disposed(by: disposeBag)
        
        subViewModels.categoryViewModel.output.isValid
            .drive(isCategoriesValid$)
            .disposed(by: disposeBag)
        
        // Child(Title)
        keyboardWithButtonHeight
            .emit(to: subViewModels.titleViewModel.input.keyboardWithButtonHeight)
            .disposed(by: disposeBag)
        
        subViewModels.titleViewModel.output.title
            .emit(to: title$)
            .disposed(by: disposeBag)
        
        subViewModels.titleViewModel.output.isValid
            .emit(to: isTitleValid$)
            .disposed(by: disposeBag)
        
        // Child(Time)
        subViewModels.timeViewModel.output.date
            .distinctUntilChanged()
            .drive(date$)
            .disposed(by: disposeBag)
        
        subViewModels.timeViewModel.output.isValid
            .emit(to: isTimeValid$)
            .disposed(by: disposeBag)
        
        // Child(Place)
        place$
            .compactMap { $0 }
            .bind(to: subViewModels.placeViewModel.input.map)
            .disposed(by: disposeBag)
        
        subViewModels.placeViewModel.output.showSearchPlaceView
            .map { _ -> SearchPlaceViewModel in
                let dependency = dependency.searchPlaceDependency
                let viewModel = SearchPlaceViewModel(dependency: dependency)
                viewModel.delegate = self
                return viewModel
            }
            .emit(to: showSearchPlaceView$)
            .disposed(by: disposeBag)
        
        subViewModels.placeViewModel.output.isValid
            .emit(to: isPlaceValid$)
            .disposed(by: disposeBag)
        
        // Child(Picture)
        picture$
            .compactMap { $0 }
            .bind(to: subViewModels.pictureViewModel.input.picture)
            .disposed(by: disposeBag)
        
        subViewModels.pictureViewModel.output.pictureButtonTapped
            .emit(to: showImagePicker$)
            .disposed(by: disposeBag)
        
        subViewModels.pictureViewModel.output.isValid
            .emit(to: isPictureValid$)
            .disposed(by: disposeBag)
        
        // Child(Plan)
        keyboardWithButtonHeight
            .emit(to: subViewModels.planViewModel.input.keyboardWithButtonHeight)
            .disposed(by: disposeBag)
        
        subViewModels.planViewModel.output.plan
            .emit(to: plan$)
            .disposed(by: disposeBag)
        
        subViewModels.planViewModel.output.isValid
            .emit(to: isPlanValid$)
            .disposed(by: disposeBag)
        
        // Child(Language)
        language$
            .compactMap { $0 }
            .bind(to: subViewModels.languageViewModel.input.language)
            .disposed(by: disposeBag)
        
        subViewModels.languageViewModel.output.showSelectLanguageView
            .map { _ -> SelectLanguageViewModel in
                let dependency = dependency.selectLanguageDependecy
                let viewModel = SelectLanguageViewModel(dependency: dependency)
                viewModel.delegate = self
                return viewModel
            }
            .emit(to: showSelectLanguageView$)
            .disposed(by: disposeBag)
        
        subViewModels.languageViewModel.output.isValid
            .emit(to: isLanguageValid$)
            .disposed(by: disposeBag)
        
        // Child(Openchat)
        keyboardWithButtonHeight
            .emit(to: subViewModels.openchatViewModel.input.keyboardWithButtonHeight)
            .disposed(by: disposeBag)
        
        subViewModels.openchatViewModel.output.openchatText
            .emit(to: openchat$)
            .disposed(by: disposeBag)
        
        subViewModels.openchatViewModel.output.isValid
            .emit(to: isOpenchatValid$)
            .disposed(by: disposeBag)
        
        // Child(Limit)
        subViewModels.limitViewModel.output.limit
            .emit(to: limit$)
            .disposed(by: disposeBag)
        
        // ContinueButton
        output.isContinueButtonEnabled
            .emit(to: subViewModels.continueButtonViewModel.input.isButtonEnabled)
            .disposed(by: disposeBag)
        
        subViewModels.continueButtonViewModel.output.continueButtonTapped
            .emit(to: continueButtonTapped$)
            .disposed(by: disposeBag)
            
    }
}

private func getContentOffset(page: Int) -> CGPoint {
    let x = UIScreen.main.bounds.width * CGFloat(page)
    return CGPoint(x: x, y: 0)
}

private func getProgression(currentPage: Int, numOfPage: Int) -> CGFloat {
    return CGFloat(currentPage + 1) / CGFloat(numOfPage)
}

private func shouldButtonEnabledWithFirst(page: Int, isCategoryValid: Bool, isTitleValid: Bool, isTimeValid: Bool, isPlaceValid: Bool, isPictureValid: Bool) -> Bool {
    switch page {
    case 0: return isCategoryValid
    case 1: return isTitleValid
    case 2: return isTimeValid
    case 3: return isPlaceValid
    case 4: return isPictureValid
    default: return false}
}

private func shouldButtonEnabledWithSecond(page: Int, isPlanValid: Bool, isLanguageValid: Bool, isOpenchatValid: Bool, isLimitValid: Bool) -> Bool {
    switch page {
    case 5: return isPlanValid
    case 6: return isLanguageValid
    case 7: return isOpenchatValid
    case 8: return isLimitValid
    default: return false}
}

private func getHangoutDetailViewModel(dependency: (user: User, hangout: Hangout, postImage: UIImage, mapImage: UIImage)) -> HangoutDetailViewModel {
        let dependency = HangoutDetailViewModel.Dependency(
            currentUser: dependency.user,
            hangout: dependency.hangout,
            postImage: dependency.postImage,
            mapImage: dependency.mapImage
        )
        return HangoutDetailViewModel(dependency: dependency)
}

private func getValue(_ result: Result<UIImage?, Error>) -> UIImage? {
    guard case .success(let value) = result else { return nil }
    return value
}

private func getError(_ result: Result<UIImage?, Error>) -> String? {
    guard case .failure(let error) = result else { return nil }
    return error.localizedDescription
}

// MARK: - SearchPlaceViewModelDelegate
extension HangoutMakeViewModel: SearchPlaceViewModelDelegate {
    func mapSelected(map: Map) {
        place$.onNext(map)
    }
}

// MARK: - SelectLanguageViewModelDelegate
extension HangoutMakeViewModel: SelectLanguageViewModelDelegate {    
    func languageSelected(language: Language) {
        language$.onNext(language)
    }
}
