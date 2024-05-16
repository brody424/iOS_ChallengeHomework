//
//  ViewModel.swift
//  iOS_ChallengeHomework
//
//  Created by 변창원 on 5/16/24.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

final class ViewModel {
    
    struct Input {
        let searchBarTextUpdate = PublishSubject<String>() // 디폴트 값을 제공하지 않아도 됩니다. 이벤트가 방출되었을 때만 처리하면 되기 때문이에요.
        let configureAllData = PublishSubject<Void>()
        let loadMoreTrigger = PublishSubject<Void>()
        
    }
    
    struct Output {
        let snapshotRelay = BehaviorRelay<NSDiffableDataSourceSnapshot<Section, SectionItem>?>(value: nil)
        let routerRelay = PublishRelay<Router>()
    }
    
    enum Router {
        case moveDetail(id: String)
    }
    
    let networkManager = NetworkManager()
    let userName: String
    var disposeBag = DisposeBag()

    var profileRelay = BehaviorRelay<GithubUser?>(value: nil)
    var repositoriesRelay = BehaviorRelay<[GithubRepository]>(value: [])

    var resultRepositories: [GithubRepository] = []
    var page = 1
    var isLoadingLast = false
    var searchKeyword = ""
    
    let output: Output
    let input: Input
    
    init(userName: String) {
        self.userName = userName
        output = Output()
        input = Input()

        bindInput()
        configureData()
    }
    
    func configureData() {
        page = 1
        isLoadingLast = false
        getUserRepositories()
        getUserProfile()
        print("Hello")
    }
    
    func bindInput() {
        input.searchBarTextUpdate.subscribe { [weak self] text in
            self?.searchKeyword = text
            self?.configureSnapshot()

        }.disposed(by: disposeBag)
        
        input.loadMoreTrigger.subscribe { [weak self] _ in
            guard let `self` = self else { return }
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
                    
                    var originRepository = self.repositoriesRelay.value
                    originRepository.append(contentsOf: repositories)
                    self.repositoriesRelay.accept(originRepository)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }

        }.disposed(by: disposeBag)
    }
    
    func getUserRepositories() {
        networkManager.fetchUserRepositories(userName: userName, page: page) { [weak self] result in
            switch result {
            case .success(let repositories):
                self?.repositoriesRelay.accept(repositories)
                self?.configureSnapshot()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getUserProfile() {
        networkManager.fetchUserProfile(userName: userName) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.profileRelay.accept(profile)
                self?.configureSnapshot()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func configureSnapshot() {
        guard let profile = profileRelay.value else { return }

        if searchKeyword.isEmpty == true {
            self.resultRepositories = self.repositoriesRelay.value
        } else {
            self.resultRepositories = self.repositoriesRelay.value.filter { $0.name.lowercased().contains(searchKeyword.lowercased()) }
        }

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
        output.snapshotRelay.accept(snapshot)
        
    }

    
}
