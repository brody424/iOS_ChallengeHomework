//
//  GithubUser.swift
//  iOS_ChallengeHomework
//
//  Created by Brody on 4/11/24.
//

import Foundation

struct GithubUser: Decodable, Hashable {
    let login: String
    let id: Int
    let avatarUrl: String
    let followers: Int
    let following: Int
    
    enum CodingKeys: String, CodingKey {
        case login
        case id
        case following, followers
        case avatarUrl = "avatar_url"
    }
}
