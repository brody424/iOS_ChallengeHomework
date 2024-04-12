//
//  GithubProfileTableViewCell.swift
//  iOS_ChallengeHomework
//
//  Created by Brody on 4/11/24.
//

import UIKit
import Kingfisher

class GithubProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImageView.layer.cornerRadius = 15
        profileImageView.clipsToBounds = true
        
        nameLabel.font = .boldSystemFont(ofSize: 16)
        idLabel.font = .systemFont(ofSize: 12)
    }

    
    func bind(_ profile: GithubUser) {
        if let imageUrl = URL(string: profile.avatarUrl) {
            profileImageView.kf.setImage(with: imageUrl)
        }
        
        nameLabel.text = profile.login
        idLabel.text = "\(profile.id)"
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
