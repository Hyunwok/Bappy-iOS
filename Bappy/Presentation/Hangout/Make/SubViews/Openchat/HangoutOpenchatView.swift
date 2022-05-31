//
//  HangoutOpenchatView.swift
//  Bappy
//
//  Created by 정동천 on 2022/05/31.
//

import UIKit
import SnapKit

final class HangoutOpenchatView: UIView {
    
    // MARK: Properties
    private let openchatFirstCaptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Please make Kakao Openchat and"
        label.font = .roboto(size: 18.0, family: .Medium)
        label.textColor = UIColor(named: "bappy_brown")
        label.numberOfLines = 2
        return label
    }()
    
    private let openchatSecondCaptionLabel: UILabel = {
        let label = UILabel()
        label.text = "write the URL of Openchat!"
        label.font = .roboto(size: 18.0, family: .Medium)
        label.textColor = UIColor(named: "bappy_brown")
        label.numberOfLines = 2
        return label
    }()
    
    private let asteriskLabel: UILabel = {
        let label = UILabel()
        label.text = "*"
        label.font = .roboto(size: 18.0)
        label.textColor = UIColor(named: "bappy_yellow")
        return label
    }()
    
    private let openchatTextField: UITextField = {
        let textField = UITextField()
        textField.font = .roboto(size: 14.0)
        textField.textColor = UIColor(named: "bappy_brown")
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter the URL",
            attributes: [.foregroundColor: UIColor(named: "bappy_gray")!])
        return textField
    }()
    
    private let underlinedView: UIView = {
        let underlinedView = UIView()
        underlinedView.backgroundColor = UIColor(red: 241.0/255.0, green: 209.0/255.0, blue: 83.0/255.0, alpha: 1.0)
        underlinedView.addBappyShadow(shadowOffsetHeight: 1.0)
        return underlinedView
    }()
    
    private let guideButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(
            NSAttributedString(
                string: "Openchat guide",
                attributes: [
                    .foregroundColor: UIColor.black.withAlphaComponent(0.33),
                    .font: UIFont.roboto(size: 10.0),
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]),
            for: .normal)
        return button
    }()
    
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
        self.backgroundColor = .white
    }
    
    private func layout() {
        let vStackView = UIStackView(arrangedSubviews: [asteriskLabel])
        vStackView.alignment = .top
        let hStackView = UIStackView(arrangedSubviews: [openchatSecondCaptionLabel, vStackView])
        hStackView.spacing = 3.0
        hStackView.alignment = .fill
        hStackView.axis = .horizontal
        
        self.addSubview(openchatFirstCaptionLabel)
        openchatFirstCaptionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(39.0)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(hStackView)
        hStackView.snp.makeConstraints {
            $0.top.equalTo(openchatFirstCaptionLabel.snp.bottom).offset(2.0)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30.0)
        }
        
        self.addSubview(openchatTextField)
        openchatTextField.snp.makeConstraints {
            $0.top.equalTo(hStackView.snp.bottom).offset(40.0)
            $0.leading.trailing.equalToSuperview().inset(47.0)
        }
        
        self.addSubview(underlinedView)
        underlinedView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(44.0)
            $0.height.equalTo(2.0)
            $0.top.equalTo(openchatTextField.snp.bottom).offset(7.0)
        }
        
        self.addSubview(guideButton)
        guideButton.snp.makeConstraints {
            $0.top.equalTo(underlinedView.snp.bottom).offset(4.0)
            $0.trailing.equalTo(underlinedView).offset(-3.0)
        }
    }
}
