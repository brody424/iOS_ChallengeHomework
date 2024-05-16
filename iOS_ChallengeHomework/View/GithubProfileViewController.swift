//
//  GithubProfileViewController.swift
//  iOS_ChallengeHomework
//
//  Created by Brody on 4/12/24.
//


//

import UIKit
import RxSwift
import RxCocoa

class GithubProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var disposeBag = DisposeBag()
    var viewModel = ViewModel(userName: "apple")
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dataSource: UITableViewDiffableDataSource<Section, SectionItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDiffableDataSource()
        configureSearchBar()
        configureTableView()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.output.snapshotRelay
            .subscribe { [weak self] snapshot in
                guard let snapshot else { return }
                self?.dataSource?.apply(snapshot)
            }.disposed(by: disposeBag)
        
        viewModel.output.routerRelay
            .subscribe { [weak self] router in
                print(router)
            }.disposed(by: disposeBag)
        
    }
    
    func configureDiffableDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, item in
            switch item {

            case .profile(let profile):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "GithubProfileTableViewCell") as? GithubProfileTableViewCell else {
                    return UITableViewCell()
                }
                
                cell.bind(profile)
                return cell

            case .repository(let repository):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "GithubRepositoryTableViewCell") as? GithubRepositoryTableViewCell else {
                    return .init()
                }

                cell.bind(repository)
                return cell
                
            case .ad(let title):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "AdTableViewCell") as? AdTableViewCell else { return UITableViewCell() }
                cell.bind(title)
                return cell
            }
            
        })
    }
    
    func configureSearchBar() {
        searchBar.rx.text
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe { [weak self] text in
                guard let `self` = self else { return }
                guard let text else { return }
                
                self.viewModel.input.searchBarTextUpdate.onNext(text)
            }.disposed(by: disposeBag)
    }
    
    func configureTableView() {
        
        tableView.register(GithubProfileTableViewCell.self, forCellReuseIdentifier: "GithubProfileTableViewCell")
        tableView.register(UINib(nibName: "GithubRepositoryTableViewCell", bundle: nil), forCellReuseIdentifier: "GithubRepositoryTableViewCell")
        tableView.register(UINib(nibName: "AdTableViewCell", bundle: nil), forCellReuseIdentifier: "AdTableViewCell")
        
//        tableView.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFire), for: .valueChanged)
        tableView.refreshControl = refreshControl
  
        tableView.rx.itemSelected
            .subscribe { [weak self] indexPath in
                guard let item = self?.dataSource?.itemIdentifier(for: indexPath) else { return }
                switch item {
                case .profile(let githubUser):
                    print(githubUser)
                case .repository(let githubRepository):
                    print(githubRepository)
                case .ad(let title):
                    print("광고문구에요! \(title)")
                }
            }.disposed(by: disposeBag)
    }
    
    @objc func refreshFire() {
        self.viewModel.input.configureAllData.onNext(())
    }
    
    func loadMore() {
        
        viewModel.input.loadMoreTrigger.onNext(())
//        if isLoadingLast == true {
//            print("마지막 페이지까지 불러왔어요.")
//            return
//        }
//        page += 1
//        networkManager.fetchUserRepositories(userName: "al45tair", page: page) { [weak self] result in
//            print("Load more api fired")
//            guard let self = `self` else { return }
//            switch result {
//            case .success(let repositories):
//                if repositories.isEmpty == true {
//                    self.isLoadingLast = true
//                    return
//                }
//
//                var originRepository = self.repositoriesSubject.value
//                originRepository.append(contentsOf: repositories)
//                self.repositoriesSubject.accept(originRepository)
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
    }
}

extension GithubProfileViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}
