//
//  ProgressBarView.swift
//  Bappy
//
//  Created by 정동천 on 2022/05/10.
//

import UIKit
import SnapKit
import RxSwift

final class ProgressBarView: UIView {
    
    // MARK: Properties
    private let yellowView = UIView()
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Helpers
    private func configure() {
        self.backgroundColor = .bappyLightgray
        yellowView.backgroundColor = .bappyYellow
    }
    
    private func layout() {
        self.snp.makeConstraints { $0.height.equalTo(9.0) }
        self.addSubview(yellowView)
        yellowView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(0)
        }
    }
}

// MARK: - Methods
extension ProgressBarView {
    func initializeProgression(_ progression: CGFloat) {
        updateProgression(progression)
    }
    
    func updateProgression(_ progression: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.yellowView.snp.updateConstraints {
                $0.top.leading.bottom.equalToSuperview()
                $0.width.equalTo(UIScreen.main.bounds.width * progression)
            }
            self.layoutIfNeeded()
        }
    }
}

// MARK: - Binder
extension Reactive where Base: ProgressBarView {
    var setProgression: Binder<CGFloat> {
        return Binder(self.base) { progressBarView, progression in
            progressBarView.updateProgression(progression)
        }
    }
    
    var initProgression: Binder<CGFloat> {
        return Binder(self.base) { progressBarView, progression in
            progressBarView.initializeProgression(progression)
        }
    }
}
