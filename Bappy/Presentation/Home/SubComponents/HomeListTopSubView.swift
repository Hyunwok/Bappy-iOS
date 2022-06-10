//
//  HomeListTopSubView.swift
//  Bappy
//
//  Created by 정동천 on 2022/06/04.
//

import UIKit
import SnapKit

protocol HomeListTopSubViewDelegate: AnyObject {
    
}
private let reuseIdentifier = "HomeListLanguageCell"
final class HomeListTopSubView: UIView {
    
    // MARK: Properties
    weak var delegate: HomeListTopSubViewDelegate?
    private var languageList = ["All", "English", "Korean"]
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HomeListLanguageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let sortingOrderButton: UIButton = {
        let button = UIButton()
        button.setAttributedTitle(
            NSAttributedString(
                string: "Newest",
                attributes: [
                    .font: UIFont.roboto(size: 18.0),
                    .foregroundColor: UIColor(named: "bappy_brown")!
                ]), for: .normal)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: false, scrollPosition: .top) // 임시
    }
    
    // MARK: Helpers
    private func configure() {
        self.backgroundColor = .white
    }
    
    private func layout() {
        let hDividingView1 = UIView()
        let hDividingView2 = UIView()
        let vDividingView = UIView()
        hDividingView1.backgroundColor = .black.withAlphaComponent(0.12)
        hDividingView2.backgroundColor = .black.withAlphaComponent(0.12)
        vDividingView.backgroundColor = .black.withAlphaComponent(0.12)
        
        let localeButtonImage = UIImage(systemName: "arrowtriangle.down.fill")
        let localeButtonImageView = UIImageView(image: localeButtonImage)
        localeButtonImageView.tintColor = UIColor(named: "bappy_yellow")
        localeButtonImageView.contentMode = .scaleToFill
        
        self.addSubview(hDividingView1)
        hDividingView1.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(14.0)
            $0.height.equalTo(1.0)
        }
        
        self.addSubview(vDividingView)
        vDividingView.snp.makeConstraints {
            $0.top.equalTo(hDividingView1.snp.bottom).offset(4.5)
            $0.trailing.equalToSuperview().inset(119.5)
            $0.width.equalTo(1.0)
            $0.height.equalTo(34.0)
        }
        
        self.addSubview(hDividingView2)
        hDividingView2.snp.makeConstraints {
            $0.top.equalTo(vDividingView.snp.bottom).offset(4.5)
            $0.leading.trailing.equalTo(hDividingView1)
            $0.height.equalTo(1.0)
            $0.bottom.equalToSuperview().inset(12.5)
        }
        
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(hDividingView1.snp.bottom)
            $0.leading.equalTo(hDividingView1)
            $0.trailing.equalTo(vDividingView.snp.leading)
            $0.bottom.equalTo(hDividingView2.snp.top)
        }
        
        self.addSubview(sortingOrderButton)
        sortingOrderButton.snp.makeConstraints {
            $0.centerY.equalTo(vDividingView)
            $0.leading.equalTo(vDividingView).offset(17.5)
//            $0.trailing.equalTo(hDividingView1)
        }
        
        sortingOrderButton.addSubview(localeButtonImageView)
        localeButtonImageView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(8.5)
            $0.width.equalTo(12.0)
            $0.height.equalTo(12.0)
            $0.trailing.equalToSuperview().inset(-18.0)
        }
    }
}
// MARK: - UICollectionViewDataSource
extension HomeListTopSubView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languageList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeListLanguageCell
        cell.isFirstCell = (indexPath.item == 0)
        if indexPath.item > 0 {
            cell.langauge = languageList[indexPath.item - 1]
        }
        return cell
    }
}

extension HomeListTopSubView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeListLanguageCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeListTopSubView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat =
        (indexPath.item == 0)
        ? 28.0
        : CGFloat(languageList[indexPath.item - 1].count) * 8.0 + 36.0
        let height: CGFloat = 43.0
        return .init(width: width, height: height)    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 11.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 3.0, bottom: 0, right: 15.0)
    }
}
