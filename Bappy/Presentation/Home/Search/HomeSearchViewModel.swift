//
//  HomeSearchViewModel.swift
//  Bappy
//
//  Created by 정동천 on 2022/07/06.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeSearchViewModel: ViewModelType {
    
    struct Dependency {}
    
    struct Input {}
    
    struct Output {}
    
    let dependency: Dependency
    var disposeBag = DisposeBag()
    let input: Input
    let output: Output
    
    init(dependency: Dependency) {
        self.dependency = dependency
        
        // MARK: Streams
        
        // MARK: Input & Output
        self.input = Input()
        
        self.output = Output()
        
        // MARK: Bindind

    }
}
