//
//  GithubProfileViewController.swift
//  iOS_ChallengeHomework
//
//  Created by Brody on 4/12/24.
//

import UIKit

class GithubProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let networkManager = NetworkManager()
    let userName = "brody424"
    @IBOutlet weak var searchBar: UISearchBar!
    
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
        
        configureSearchBar()
        configureTableView()
        configureData()
    }
    
    func configureData() {
        page = 1
        isLoadingLast = false
        
        let dispatchGroup = DispatchGroup()

        getUserRepositories(dispatchGroup)
        getUserProfile(dispatchGroup)
	        
        dispatchGroup.notify(queue: .main) {
            self.tableView.reloadData()
        }

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
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
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
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension GithubProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "GithubProfileTableViewCell") as? GithubProfileTableViewCell else {
                return UITableViewCell()
            }
            
            if let profile {
                cell.bind(profile)
            }
            
            return cell
            
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "GithubRepositoryTableViewCell") as? GithubRepositoryTableViewCell else {
                return .init()
            }
            
            let repository = resultRepositories[indexPath.row]
            cell.bind(repository)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return resultRepositories.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 120
        } else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == repositories.count - 1 {
            if searchBar.text?.isEmpty == true {
                loadMore()
            }
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
        tableView.reloadData()
    }
}
