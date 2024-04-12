//
//  NetworkManager.swift
//  iOS_ChallengeHomework
//
//  Created by Brody on 4/11/24.
//

import Foundation
import Alamofire

final class NetworkManager {
    let url = "https://api.github.com/users/"
    
    func fetchUserProfile(userName: String, completion: @escaping ((Result<GithubUser, Error>) -> Void)) {
        guard let url = URL(string: "\(self.url)\(userName)") else {
            completion(.failure(NSError(domain: "URL 변환에 실패했어요.", code: 401)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // GET, POST <- 이건 무조건 알아야 합니다.
        // GET, POST 의 차이점에 대해서도 알아두시면 아주 좋아요.
        // PUT, DELETE, PATCH <- 이런것도 있는걸 알아두시면 좋아요.
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let data else {
                completion(.failure(NSError(domain: "Data가 없어요.", code: 402)))
                return
            }
            
            do {
                let user = try JSONDecoder().decode(GithubUser.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
            
        }
        
        task.resume()
    }
    
    func fetchUserRepositories(userName: String, page: Int, completion: @escaping (Result<[GithubRepository], Error>) -> Void) {
        let url = "\(self.url)\(userName)/repos?page=\(page)"
        
        AF.request(url).responseDecodable(of: [GithubRepository].self) { response in
            switch response.result {
            case .success(let repositories):
                completion(.success(repositories))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
