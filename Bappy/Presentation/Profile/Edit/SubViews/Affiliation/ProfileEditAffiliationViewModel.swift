//
//  ProfileEditAffiliationViewModel.swift
//  Bappy
//
//  Created by 정동천 on 2022/07/04.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileEditAffiliationViewModel: ViewModelType {
    
    struct Dependency {
        let user: BappyUser
        var affiliation: String { "No Contents" }
        var maximumLength: Int { 100 }
    }
    
    struct Input {
        var text: AnyObserver<String> // <-> View
    }
    
    struct Output {
        var placeHolder: Driver<String> // <-> View
        var shouldHidePlaceHolder: Driver<Bool> // <-> View
        var modifiedText: Signal<String> // <-> View
        var edittedAffiliation: Signal<String?> // <-> Parent
    }
    
    let dependency: Dependency
    var disposeBag = DisposeBag()
    let input: Input
    let output: Output
    
    private let user$: BehaviorSubject<BappyUser>
    private let maximumLength$: BehaviorSubject<Int>
    
    private let text$ = BehaviorSubject<String>(value: "")
  
    init(dependency: Dependency) {
        self.dependency = dependency
        
        // MARK: Streams
        let user$ = BehaviorSubject<BappyUser>(value: dependency.user)
        let maximumLength$ = BehaviorSubject<Int>(value: dependency.maximumLength)
        
        let placeHolder = user$
            .map { $0.affiliation ?? "" }
            .map { $0.isEmpty ? dependency.affiliation : $0 }
            .asDriver(onErrorJustReturn: dependency.affiliation)
        let shouldHidePlaceHolder = text$
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
        let modifiedText = text$
            .withLatestFrom(maximumLength$, resultSelector: removeExcessString)
            .asSignal(onErrorJustReturn: "")
        let edittedAffiliation = text$
            .withLatestFrom(maximumLength$, resultSelector: removeExcessString)
            .map { !$0.isEmpty ? $0 : nil }
            .asSignal(onErrorJustReturn: nil)
        
        // MARK: Input & Output
        self.input = Input(
            text: text$.asObserver()
        )
        
        self.output = Output(
            placeHolder: placeHolder,
            shouldHidePlaceHolder: shouldHidePlaceHolder,
            modifiedText: modifiedText,
            edittedAffiliation: edittedAffiliation
        )
        
        // MARK: Bindind
        self.user$ = user$
        self.maximumLength$ = maximumLength$
    }
}

private func removeExcessString(text: String, maximumLength: Int) -> String {
    guard text.count > maximumLength else { return text }
    let startIndex = text.startIndex
    let lastIndex = text.index(startIndex, offsetBy: maximumLength)
    return String(text[startIndex..<lastIndex])
}
