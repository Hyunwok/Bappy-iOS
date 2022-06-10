//
//  HangoutParticipantsSectionView.swift
//  Bappy
//
//  Created by 정동천 on 2022/05/23.
//

import UIKit
import SnapKit

private let reuseIdentifier = "ParticipantImageCell"
final class HangoutParticipantsSectionView: UIView {
    
    // MARK: Properties
    private let joinCaptionLabel: UILabel = {
        let label = UILabel()
        label.font = .roboto(size: 20.0, family: .Medium)
        label.text = "Who Join?"
        label.textColor = UIColor(named: "bappy_brown")
        return label
    }()
    
    private let numOfParticipantsLabel: UILabel = {
        let label = UILabel()
        label.font = .roboto(size: 16.0)
        label.text = "1 in 5"
        label.textColor = UIColor(named: "bappy_brown")
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(ParticipantImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let reportButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "detail_report"), for: .normal)
        button.imageEdgeInsets = .init(top: 12.5, left: 13.0, bottom: 12.5, right: 13.0)
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
        self.addSubview(joinCaptionLabel)
        joinCaptionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8.0)
            $0.leading.equalToSuperview().inset(27.0)
        }
        
        self.addSubview(reportButton)
        reportButton.snp.makeConstraints {
            $0.leading.equalTo(joinCaptionLabel.snp.trailing).offset(-3.0)
            $0.centerY.equalTo(joinCaptionLabel)
            $0.width.height.equalTo(44.0)
        }
        
        self.addSubview(numOfParticipantsLabel)
        numOfParticipantsLabel.snp.makeConstraints {
            $0.bottom.equalTo(joinCaptionLabel)
            $0.trailing.equalToSuperview().inset(23.0)
        }
        
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(joinCaptionLabel.snp.bottom).offset(15.0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48.0)
            $0.bottom.equalToSuperview().inset(16.0)
        }
    }
}

// MARK: UICollectionViewDataSource
extension HangoutParticipantsSectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ParticipantImageCell
        cell.size = .medium
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension HangoutParticipantsSectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 22.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48.0, height: 48.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 33.0, bottom: 0, right: 0)
    }
}
