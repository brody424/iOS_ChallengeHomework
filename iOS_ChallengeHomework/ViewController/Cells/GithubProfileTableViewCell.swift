//
//  GithubProfileTableViewCell.swift
//  iOS_ChallengeHomework
//
//  Created by Brody on 4/18/24.
//

import UIKit
import Kingfisher
import SnapKit

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
        
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.leading.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10).priority(999)
        }
        
        idLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.trailing.equalToSuperview().inset(10)
            make.leading.equalTo(profileImageView.snp.trailing).inset(-10)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(idLabel.snp.top).inset(-20)
            make.trailing.equalToSuperview().inset(10)
            make.leading.equalTo(profileImageView.snp.trailing).inset(-10)
        }
        
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
