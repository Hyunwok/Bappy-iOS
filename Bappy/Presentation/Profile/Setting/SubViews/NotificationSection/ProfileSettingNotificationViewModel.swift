//
//  ProfileSettingNotificationViewModel.swift
//  Bappy
//
//  Created by 정동천 on 2022/07/21.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileSettingNotificationViewModel: ViewModelType {
    
    struct Dependency {}
    
    struct Input {
    }
    
    struct Output {
    }
    
    let dependency: Dependency
    var disposeBag = DisposeBag()
    let input: Input
    let output: Output
  
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        // MARK: Streams
        
        // MARK: Input & Output
        self.input = Input(
        )
        
        self.output = Output(
        )
        
        // MARK: Bindind
    }
}
