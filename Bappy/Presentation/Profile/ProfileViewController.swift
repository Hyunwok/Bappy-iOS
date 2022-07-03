//
//  ProfileViewController.swift
//  Bappy
//
//  Created by 정동천 on 2022/05/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

private let reuseIdentifier = "ProfileHangoutCell"
final class ProfileViewController: UIViewController {
    
    // MARK: Properties
    private let viewModel: ProfileViewModel
    private let disposeBag = DisposeBag()
    
    private let titleTopView = TitleTopView(title: "Profile", subTitle: "Bappy user")
    private let headerView: ProfileHeaderView
    private let settingButton = UIButton()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .bappyLightgray
        tableView.register(ProfileHangoutCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 157.0
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: Lifecycle
    init(viewModel: ProfileViewModel) {
        let headerViewModel = viewModel.subViewModels.headerViewModel
        self.headerView = ProfileHeaderView(viewModel: headerViewModel)
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        configure()
        layout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setStatusBarStyle(statusBarStyle: .lightContent)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setStatusBarStyle(statusBarStyle: .darkContent)
    }
    
    // MARK: Helpers
    private func setStatusBarStyle(statusBarStyle: UIStatusBarStyle) {
        guard let navigationController = navigationController as? BappyNavigationViewController else { return }
        navigationController.statusBarStyle = statusBarStyle
    }
    
    private func configure() {
        view.backgroundColor = .white
        
        tableView.tableHeaderView = headerView
        headerView.frame.size.height = 352.0
        settingButton.setImage(UIImage(named: "profile_setting"), for: .normal)
        settingButton.isHidden = true
    }
    
    private func layout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(titleTopView)
        titleTopView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(94.0)
            $0.bottom.equalTo(tableView.snp.top)
        }
        
        titleTopView.addSubview(settingButton)
        settingButton.snp.makeConstraints {
            $0.width.height.equalTo(44.0)
            $0.trailing.equalToSuperview().inset(21.3)
            $0.bottom.equalToSuperview().inset(48.6)
        }
    }
}

// MARK: - Bind
extension ProfileViewController {
    private func bind() {
        tableView.rx.didScroll
            .withLatestFrom(tableView.rx.contentOffset)
            .observe(on: MainScheduler.asyncInstance)
            .filter { $0.y < 0 }
            .map { CGPoint(x: $0.x, y: 0) }
            .bind(to: tableView.rx.contentOffset)
            .disposed(by: disposeBag)
        
        settingButton.rx.tap
            .bind(to: viewModel.input.settingButtonTapped)
            .disposed(by: disposeBag)
        
        viewModel.output.hangouts
            .drive(tableView.rx.items) { tableView, row, item in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: reuseIdentifier,
                    for: IndexPath(row: row, section: 0)
                ) as! ProfileHangoutCell
                cell.selectionStyle = .none
                return cell
            }
            .disposed(by: disposeBag)
        
        viewModel.output.showSettingView
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] viewModel in
                let viewController = ProfileSettingViewController(viewModel: viewModel)
                viewController.modalPresentationStyle = .fullScreen
                viewController.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.showDetailView
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] viewModel in
                let viewController = ProfileDetailViewController(viewModel: viewModel)
                viewController.modalPresentationStyle = .fullScreen
                viewController.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.hideSettingButton
            .emit(to: settingButton.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
