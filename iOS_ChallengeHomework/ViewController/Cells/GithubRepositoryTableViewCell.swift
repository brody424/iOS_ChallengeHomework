//
//  GithubRepositoryTableViewCell.swift
//  iOS_ChallengeHomework
//
//  Created by Brody on 4/11/24.
//

import UIKit
import RxSwift

class GithubRepositoryTableViewCell: UITableViewCell {

    // 오토레이아웃 Priority Hugging vs Compression 알아보면 좋아요.
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var button: UIButton!
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(_ repository: GithubRepository) {
        nameLabel.text = repository.name
        languageLabel.text = repository.language ?? ""
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
