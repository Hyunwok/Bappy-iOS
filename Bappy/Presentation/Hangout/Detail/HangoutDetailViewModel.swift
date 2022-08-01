//
//  HangoutDetailViewModel.swift
//  Bappy
//
//  Created by 정동천 on 2022/06/24.
//

import UIKit
import RxSwift
import RxCocoa

final class HangoutDetailViewModel: ViewModelType {
    
    struct SubViewModels {
        let imageSectionViewModel: HangoutImageSectionViewModel
        let mainSectionViewModel: HangoutMainSectionViewModel
        let mapSectionViewModel: HangoutMapSectionViewModel
        let planSectionViewModel: HangoutPlanSectionViewModel
        let participantsSectionViewModel: HangoutParticipantsSectionViewModel
    }
    
    struct Dependency {
        let firebaseRepository: FirebaseRepository
        let userProfileRepository: UserProfileRepository
        var currentUser: BappyUser
        var hangout: Hangout
        var postImage: UIImage?
        var mapImage: UIImage?
        
        var isUserParticipating: Bool {
            return hangout.participantIDs
                .map(\.id)
                .contains(currentUser.id)
        }
        
        var hangoutButtonState: HangoutButton.State {
            switch hangout.state {
            case .preview: return .create
            case .closed: return .closed
            case .expired: return . expired
            case .available: return isUserParticipating ? .cancel : .join }
        }
        
        init(firebaseRepository: FirebaseRepository, userProfileRepository: UserProfileRepository, currentUser: BappyUser, hangout: Hangout, postImage: UIImage? = nil, mapImage: UIImage? = nil) {
            self.firebaseRepository = firebaseRepository
            self.userProfileRepository = userProfileRepository
            self.currentUser = currentUser
            self.hangout = hangout
            self.postImage = postImage
            self.mapImage = mapImage
        }
    }
    
    struct Input {
        var backButtonTapped: AnyObserver<Void> // <-> View
        var hangoutButtonTapped: AnyObserver<Void> // <-> View
        var reportButtonTapped: AnyObserver<Void> // <-> View
        var imageHeight: AnyObserver<CGFloat> // <-> View
        var cancelAlertButtonTapped: AnyObserver<Void> // <-> View
        var mapButtonTapped: AnyObserver<Void> // <-> Child(Map)
        var selectedUserID: AnyObserver<String> // <-> Child(Participants)
    }
    
    struct Output {
        var popView: Signal<Void> // <-> View
        var imageHeight: Signal<CGFloat> // <-> Child(Map)
        var showOpenMapView: Signal<OpenMapPopupViewModel> // <-> View
        var hangoutButtonState: Signal<HangoutButton.State> // <-> View
        var showSignInAlert: Signal<String?> // <-> View
        var showCancelAlert: Signal<Alert?> // <-> View
        var showReportView: Signal<ReportViewModel?> // <-> View
        var showUserProfile: Signal<ProfileViewModel?> // <-> View
    }
    
    let dependency: Dependency
    var disposeBag = DisposeBag()
    let input: Input
    let output: Output
    let subViewModels: SubViewModels
    
    private let hangoutButtonState$: BehaviorSubject<HangoutButton.State>
    private let isUserParticipating$: BehaviorSubject<Bool>
    private let currentUser$: BehaviorSubject<BappyUser>
    private let reasonsForReport$ = BehaviorSubject<[String]?>(value: nil)
    
    private let backButtonTapped$ = PublishSubject<Void>()
    private let hangoutButtonTapped$ = PublishSubject<Void>()
    private let reportButtonTapped$ = PublishSubject<Void>()
    private let imageHeight$ = PublishSubject<CGFloat>()
    private let cancelAlertButtonTapped$ = PublishSubject<Void>()
    private let mapButtonTapped$ = PublishSubject<Void>()
    private let selectedUserID$ = PublishSubject<String>()
    
    private let showCancelAlert$ = PublishSubject<Alert?>()
    private let showUserProfile$ = PublishSubject<ProfileViewModel?>()
    
    init(dependency: Dependency) {
        let imageDependency = HangoutImageSectionViewModel.Dependency(
            isPreviewMode: dependency.hangout.state == .preview,
            postImageURL: dependency.hangout.postImageURL,
            postImage: dependency.postImage,
            userHasLiked: dependency.hangout.userHasLiked)
        let mainDependency = HangoutMainSectionViewModel.Dependency(
            isUserParticipating: dependency.isUserParticipating,
            title: dependency.hangout.title,
            meetTime: dependency.hangout.meetTime,
            language: dependency.hangout.language,
            placeName: dependency.hangout.placeName,
            openchatURL: dependency.hangout.openchatURL)
        let mapDependency = HangoutMapSectionViewModel.Dependency(
            isPreviewModel: dependency.hangout.state == .preview,
            placeName: dependency.hangout.placeName,
            mapImageURL: dependency.hangout.mapImageURL,
            mapImage: dependency.mapImage)
        let planDependency = HangoutPlanSectionViewModel.Dependency(
            plan: dependency.hangout.plan)
        let participantsDependency = HangoutParticipantsSectionViewModel.Dependency(
            limitNumber: dependency.hangout.limitNumber,
            participantIDs: dependency.hangout.participantIDs)
        
        self.dependency = dependency
        self.subViewModels = SubViewModels(
            imageSectionViewModel: HangoutImageSectionViewModel(dependency: imageDependency),
            mainSectionViewModel: HangoutMainSectionViewModel(dependency: mainDependency),
            mapSectionViewModel: HangoutMapSectionViewModel(dependency: mapDependency),
            planSectionViewModel: HangoutPlanSectionViewModel(dependency: planDependency),
            participantsSectionViewModel: HangoutParticipantsSectionViewModel(dependency: participantsDependency)
        )
        
        // MARK: Streams
        let hangoutButtonState$ = BehaviorSubject<HangoutButton.State>(value: dependency.hangoutButtonState)
        let isUserParticipating$ = BehaviorSubject<Bool>(value: dependency.isUserParticipating)
        let currentUser$ = BehaviorSubject<BappyUser>(value: dependency.currentUser)
        
        let popView = backButtonTapped$
            .asSignal(onErrorJustReturn: Void())
        let imageHeight = imageHeight$
            .asSignal(onErrorJustReturn: 0)
        let showOpenMapView = mapButtonTapped$
            .map { _ -> OpenMapPopupViewModel in
                let dependency = OpenMapPopupViewModel.Dependency(
                    googleMapURL: dependency.hangout.googleMapURL,
                    kakaoMapURL: dependency.hangout.kakaoMapURL)
                return OpenMapPopupViewModel(dependency: dependency)
            }
            .asSignal(onErrorJustReturn: OpenMapPopupViewModel(dependency: .init(
                googleMapURL: dependency.hangout.googleMapURL,
                kakaoMapURL: dependency.hangout.kakaoMapURL
            )))
        let hangoutButtonState = hangoutButtonState$
            .asSignal(onErrorJustReturn: .expired)
        let showSignInAlert = Observable
            .merge(
                hangoutButtonTapped$
                    .withLatestFrom(hangoutButtonState$)
                    .filter { $0 == .join }
                    .withLatestFrom(currentUser$)
                    .filter { $0.state == .anonymous }
                    .map { _ in "Please sign in to join!" },
                selectedUserID$
                    .withLatestFrom(currentUser$)
                    .filter { $0.state == .anonymous}
                    .map { _ in "Sign in to check other's profiles!" }
            )
            .asSignal(onErrorJustReturn: nil)
        let showCancelAlert = showCancelAlert$
            .asSignal(onErrorJustReturn: nil)
        let showReportView = reportButtonTapped$
            .withLatestFrom(reasonsForReport$)
            .compactMap { reasons -> ReportViewModel? in
                guard let reasons = reasons else { return nil }
                let dependency = ReportViewModel.Dependency(dropdownList: reasons)
                return ReportViewModel(dependency: dependency)
            }
            .asSignal(onErrorJustReturn: nil)
        let showUserProfile = showUserProfile$
            .asSignal(onErrorJustReturn: nil)
        
        // MARK: Input & Output
        self.input = Input(
            backButtonTapped: backButtonTapped$.asObserver(),
            hangoutButtonTapped: hangoutButtonTapped$.asObserver(),
            reportButtonTapped: reportButtonTapped$.asObserver(),
            imageHeight: imageHeight$.asObserver(),
            cancelAlertButtonTapped: cancelAlertButtonTapped$.asObserver(),
            mapButtonTapped: mapButtonTapped$.asObserver(),
            selectedUserID: selectedUserID$.asObserver()
        )
        
        self.output = Output(
            popView: popView,
            imageHeight: imageHeight,
            showOpenMapView: showOpenMapView,
            hangoutButtonState: hangoutButtonState,
            showSignInAlert: showSignInAlert,
            showCancelAlert: showCancelAlert,
            showReportView: showReportView,
            showUserProfile: showUserProfile
        )
        
        // MARK: Bindind
        self.hangoutButtonState$ = hangoutButtonState$
        self.isUserParticipating$ = isUserParticipating$
        self.currentUser$ = currentUser$
        
        hangoutButtonTapped$
            .withLatestFrom(hangoutButtonState$)
            .filter { $0 == .cancel }
            .map { _ -> Alert in
                let title = "Will you really cancel?\nPlease leave the chat room first!"
                let message = "Bappy friends are looking\nforward to seeing you"
                let actionTitle = "Cancel"
                let action = Alert.Action(
                    actionTitle: actionTitle) { [weak self] in
                        self?.input.cancelAlertButtonTapped.onNext(Void())
                    }
                return Alert(
                    title: title,
                    message: message,
                    bappyStyle: .sad,
                    action: action
                )
            }
            .bind(to: showCancelAlert$)
            .disposed(by: disposeBag)
        
        let remoteConfigValuesResult = dependency.firebaseRepository.getRemoteConfigValues()
            .share()
        
        remoteConfigValuesResult
            .compactMap(getRemoteConfigValuesError)
            .bind(onNext: { print("ERROR: \($0)") })
            .disposed(by: disposeBag)
        
        remoteConfigValuesResult
            .compactMap(getRemoteConfigValues)
            .map(\.reasonsForReport)
            .bind(to: reasonsForReport$)
            .disposed(by: disposeBag)
        
        let bappyUserResult = selectedUserID$
            .withLatestFrom(currentUser$) { ($0, $1)}
            .filter { $1.state == .normal }
            .map(\.0)
            .flatMap(dependency.userProfileRepository.fetchBappyUser)
            .observe(on: MainScheduler.asyncInstance)
            .share()
        
        bappyUserResult
            .compactMap(getBappyUserError)
            .bind(onNext: { print("ERROR: \($0)") })
            .disposed(by: disposeBag)
        
        bappyUserResult
            .compactMap(getBappyUser)
            .map { user -> ProfileViewModel in
                let dependency = ProfileViewModel.Dependency(
                    user: user,
                    authorization: .view,
                    bappyAuthRepository: DefaultBappyAuthRepository.shared)
                return ProfileViewModel(dependency: dependency)
            }
            .bind(to: showUserProfile$)
            .disposed(by: disposeBag)
        
        // Child(Image)
        imageHeight
            .emit(to: subViewModels.imageSectionViewModel.input.imageHeight)
            .disposed(by: disposeBag)
        
        // Child(Map)
        subViewModels.mapSectionViewModel.output.mapButtonTapped
            .emit(to: input.mapButtonTapped)
            .disposed(by: disposeBag)
        
        // Child(Participants)
        subViewModels.participantsSectionViewModel.output.selectedUserID
            .compactMap { $0 }
            .emit(to: input.selectedUserID)
            .disposed(by: disposeBag)
    }
}

private func getRemoteConfigValues(_ result: Result<RemoteConfigValues, Error>) -> RemoteConfigValues? {
    guard case .success(let value) = result else { return nil }
    return value
}

private func getRemoteConfigValuesError(_ result: Result<RemoteConfigValues, Error>) -> String? {
    guard case .failure(let error) = result else { return nil }
    return error.localizedDescription
}

private func getBappyUser(_ result: Result<BappyUser, Error>) -> BappyUser? {
    guard case .success(let value) = result else { return nil }
    return value
}

private func getBappyUserError(_ result: Result<BappyUser, Error>) -> String? {
    guard case .failure(let error) = result else { return nil }
    return error.localizedDescription
}
