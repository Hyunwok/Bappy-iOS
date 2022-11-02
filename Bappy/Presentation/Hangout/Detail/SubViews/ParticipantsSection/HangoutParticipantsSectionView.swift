//
//  HangoutParticipantsSectionView.swift
//  Bappy
//
//  Created by 정동천 on 2022/05/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class HangoutParticipantsSectionView: UIView {
    
    // MARK: Properties
    private let viewModel: HangoutParticipantsSectionViewModel
    private let disposeBag = DisposeBag()
    
    private let heartImageView: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "heart-line")!.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage( UIImage(named: "heart_fill")!.withRenderingMode(.alwaysTemplate), for: .selected)
        button.tintColor = .red
        button.isEnabled = true
        return button
    }()
    
    private let likedPeopleCountLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "+0"
        lbl.font = .roboto(size: 14)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let likedPeopleStackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 6
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private let joinCaptionLabel: UILabel = {
        let label = UILabel()
        label.font = .roboto(size: 20.0, family: .Medium)
        label.text = "Who Join?"
        label.textColor = .bappyBrown
        return label
    }()
    
    private let numOfParticipantsLabel: UILabel = {
        let label = UILabel()
        label.font = .roboto(size: 16.0)
        label.textColor = .bappyBrown
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 22.0
        flowLayout.itemSize = .init(width: 48.0, height: 48.0)
        flowLayout.sectionInset = .init(top: 0, left: 33.0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(ParticipantImageCell.self, forCellWithReuseIdentifier: ParticipantImageCell.reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: Lifecycle
    init(viewModel: HangoutParticipantsSectionViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        configure()
        layout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Helpers
    private func configure() {
        self.backgroundColor = .white
    }
    
    private func layout() {
        self.addSubviews([joinCaptionLabel, numOfParticipantsLabel, collectionView, heartImageView, likedPeopleCountLbl, likedPeopleStackView])
        
        joinCaptionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8.0)
            $0.leading.equalToSuperview().inset(27.0)
        }
        
        numOfParticipantsLabel.snp.makeConstraints {
            $0.bottom.equalTo(joinCaptionLabel)
            $0.trailing.equalToSuperview().inset(23.0)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(joinCaptionLabel.snp.bottom).offset(15.0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48.0)
        }
        
        heartImageView.snp.makeConstraints {
            $0.width.height.equalTo(32)
            $0.top.equalTo(collectionView.snp.bottom).offset(16)
            $0.bottom.equalToSuperview()
        }
        
        likedPeopleCountLbl.snp.makeConstraints {
            $0.leading.equalTo(heartImageView.snp.trailing).offset(4)
            $0.bottom.equalToSuperview()
            $0.centerY.equalTo(heartImageView)
        }
        
        likedPeopleStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(33)
            $0.height.equalTo(32)
            $0.centerY.equalTo(heartImageView)
            $0.leading.equalTo(likedPeopleCountLbl.snp.trailing).offset(14)
        }
    }
}

// MARK: - Bind
extension HangoutParticipantsSectionView {
    private func bind() {
        collectionView.rx.modelSelected(Hangout.Info.self)
            .map(\.id)
            .bind(to: viewModel.input.selectedUserID)
            .disposed(by: disposeBag)
        
        viewModel.output.limitNumberText
            .emit(to: numOfParticipantsLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.joinedIDs
            .drive(collectionView.rx.items(cellIdentifier: ParticipantImageCell.reuseIdentifier, cellType: ParticipantImageCell.self)) { _, element, cell in
                cell.bind(with: element.imageURL)
            }.disposed(by: disposeBag)
        
        viewModel.output.likedIDs
            .drive { [weak self] infos in
                guard let self = self else { return }
                print("infos!", infos)
                self.likedPeopleStackView.arrangedSubviews.map { $0.removeFromSuperview() }
                self.heartImageView.isSelected = !infos.isEmpty
                self.likedPeopleCountLbl.text = "+\(infos.count)"
                for idx in 0..<infos.count {
                    if idx > 4 { return }
                    let info = infos[idx]
                    
                    let button = CircleProfileView(info: info)
                    
                    if idx == 4 { button.isLastView = true; button.info = Hangout.Info(id: "", imageURL: info.imageURL) }
                    
                    button.rx.tap
                        .map { button.info.id }
                        .bind(to: self.viewModel.input.selectedUserID)
                        .disposed(by: self.disposeBag)
                    
                    
                    self.likedPeopleStackView.addArrangedSubview(button)
                }
            }.disposed(by: disposeBag)
    }
}

final class CircleProfileView: UIButton {
    var info: Hangout.Info
    var viewSize: CGFloat = 32
    private let lastImageView = UIImageView()
    
    var lastImage: UIImage? {
        set {
            self.lastImageView.image = newValue
        } get {
            return self.lastImageView.image
        }
    }
    
    var isLastView: Bool {
        set {
            self.backgroundColor = newValue ? .black.withAlphaComponent(0.8) : .none
            self.lastImageView.isHidden = !newValue
        } get {
            return self.lastImageView.isHidden
        }
    }
    
    var isSelectable: Bool {
        set {
            self.isEnabled = !newValue
        } get {
            return self.isEnabled
        }
    }
    
    var size: CGFloat {
        set {
            self.viewSize = newValue
        } get {
            return self.viewSize
        }
    }
    
    init(info: Hangout.Info) {
        self.info = info
        super.init(frame: .zero)
        
        configure()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        self.kf.setImage(with: info.imageURL, for: .normal, placeholder: UIImage(named: "hangout_no_profile"))
        self.lastImageView.image = UIImage(systemName: "plus")
        self.lastImageView.isHidden = true
        self.clipsToBounds = true
        self.layer.cornerRadius = viewSize / 2
        
        if isLastView {
            self.backgroundColor = .black.withAlphaComponent(0.5)
        }
         
        self.addSubview(lastImageView)
    }
    
    func layout() {
        self.snp.makeConstraints {
            $0.width.height.equalTo(viewSize)
        }
        
        lastImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
    }
}
