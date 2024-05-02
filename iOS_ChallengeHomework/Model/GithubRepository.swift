//
//  GithubRepository.swift
//  iOS_ChallengeHomework
//
//  Created by Brody on 4/11/24.
//

import Foundation

struct GithubRepository: Decodable, Hashable {
    let name: String
    let language: String?
}
