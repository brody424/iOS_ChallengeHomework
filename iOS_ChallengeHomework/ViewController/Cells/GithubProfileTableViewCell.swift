//
//  GithubProfileTableViewCell.swift
//  iOS_ChallengeHomework
//
//  Created by Brody on 4/18/24.
//

import UIKit
import Kingfisher

class GithubProfileTableViewCell: UITableViewCell {
        
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12.0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    func configureView() {
        
        addSubview(profileImageView)
        addSubview(idLabel)
        addSubview(nameLabel)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor, multiplier: 1.0),
            profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),

            idLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 50),
            idLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            idLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10.0),
            
            nameLabel.topAnchor.constraint(equalTo: idLabel.topAnchor, constant: -20),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10.0),
        ])
        
    }
    
    func bind(_ user: GithubUser) {
        if let imageUrl = URL(string: user.avatarUrl) {
            profileImageView.kf.setImage(with: imageUrl)
        }
        
        idLabel.text = user.login
        
        nameLabel.text = "\(user.id)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
