//
//  GithubProfileViewController.swift
//  iOS_ChallengeHomework
//
//  Created by Brody on 4/12/24.
//


//

/**
 심화과정을 살짝 보니까
- MVC vs MVVM
- 디자인 패턴
- RxSwift

 MVVM + RxSwift

 UIKit + RxSwift
 SwiftUI + Combine
 
 js async await
 Promise
 */
import UIKit

class GithubProfileViewController: UIViewController {

    enum Section {
        case profile
        case repositories
    }
    
    enum SectionItem: Hashable {
        case profile(GithubUser)
        case repository(GithubRepository)
        case ad(String)
    }
    
    @IBOutlet weak var tableView: UITableView!

    let networkManager = NetworkManager()
    let userName = "brody424"

    @IBOutlet weak var searchBar: UISearchBar!
    
    var dataSource: UITableViewDiffableDataSource<Section, SectionItem>?
    
    var profile: GithubUser?
    var repositories: [GithubRepository] = [] {
        didSet {
            resultRepositories = repositories
        }
    }
    var resultRepositories: [GithubRepository] = []
    var page = 1
    var isLoadingLast = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDiffableDataSource()
        configureSearchBar()
        configureTableView()
        configureData()
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
    
    func configureData() {
        page = 1
        isLoadingLast = false
        
        let dispatchGroup = DispatchGroup()

        getUserRepositories(dispatchGroup)
        getUserProfile(dispatchGroup)
	        
        dispatchGroup.notify(queue: .main) {
            self.applySnapshot()
        }
    }
    
    func applySnapshot() {
        guard let profile else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>()
        snapshot.appendSections([.profile])
        snapshot.appendItems([.profile(profile)])
        
        snapshot.appendSections([.repositories])
        
        var items:[SectionItem] = resultRepositories.map({
            .repository($0)
        })
        
        if resultRepositories.count > 5 {
            items.insert(.ad("첫번째 광고에요"), at: 3)
        }
        if resultRepositories.count > 10 {
            items.insert(.ad("두번째 광고에요"), at: 6)
        }

        snapshot.appendItems(items)
        dataSource?.apply(snapshot)
    }
    
    func getUserRepositories(_ group: DispatchGroup) {
        group.enter()
        networkManager.fetchUserRepositories(userName: userName, page: page) { [weak self] result in
            group.leave()
            switch result {
            case .success(let repositories):
                self?.repositories = repositories
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getUserProfile(_ group: DispatchGroup) {
        group.enter()
        networkManager.fetchUserProfile(userName: userName) { [weak self] result in
            group.leave()
            switch result {
            case .success(let profile):
                self?.profile = profile
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func configureSearchBar() {
        searchBar.delegate = self
    }
    
    func configureTableView() {
        
        tableView.register(GithubProfileTableViewCell.self, forCellReuseIdentifier: "GithubProfileTableViewCell")
        tableView.register(UINib(nibName: "GithubRepositoryTableViewCell", bundle: nil), forCellReuseIdentifier: "GithubRepositoryTableViewCell")
        tableView.register(UINib(nibName: "AdTableViewCell", bundle: nil), forCellReuseIdentifier: "AdTableViewCell")
        
        tableView.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFire), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func refreshFire() {
        configureData()
    }
    
    func loadMore() {
        if isLoadingLast == true {
            print("마지막 페이지까지 불러왔어요.")
            return
        }
        page += 1
        networkManager.fetchUserRepositories(userName: "al45tair", page: page) { [weak self] result in
            print("Load more api fired")
            guard let self = `self` else { return }
            switch result {
            case .success(let repositories):
                if repositories.isEmpty == true {
                    self.isLoadingLast = true
                    return
                }
                self.repositories = self.repositories + repositories
                self.applySnapshot()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension GithubProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = self.dataSource?.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .profile(let githubUser):
            print(githubUser)
        case .repository(let githubRepository):
            print(githubRepository)
        case .ad(let title):
            print("광고문구에요! \(title)")
        }
    }
}

extension GithubProfileViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty == true {
            resultRepositories = repositories
        } else {
            resultRepositories = repositories.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        self.applySnapshot()
    }
}
