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
    
    var profile: GithubUser?
    var repositories: [GithubRepository] = []
    var page = 1
    var isLoadingLast = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureData()
    }
    
    func configureData() {
        page = 1
        isLoadingLast = false
        
        networkManager.fetchUserProfile(userName: userName) { [weak self] result in
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
        
        networkManager.fetchUserRepositories(userName: "al45tair", page: page) { [weak self] result in
            switch result {
            case .success(let repositories):
                self?.repositories = repositories
                DispatchQueue.main.async {
                    self?.tableView.refreshControl?.endRefreshing()
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
            
            let repository = repositories[indexPath.row]
            cell.bind(repository)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return repositories.count
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
            loadMore()
        }
    }
}
