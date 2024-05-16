//
//  SectionModel.swift
//  iOS_ChallengeHomework
//
//  Created by 변창원 on 5/16/24.
//

import Foundation

enum Section {
    case profile
    case repositories
}

enum SectionItem: Hashable {
    case profile(GithubUser)
    case repository(GithubRepository)
    case ad(String)
}
