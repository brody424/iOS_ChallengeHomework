//
//  AdTableViewCell.swift
//  iOS_ChallengeHomework
//
//  Created by 변창원 on 5/2/24.
//

import UIKit

class AdTableViewCell: UITableViewCell {

    @IBOutlet weak var adTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        adTitle.layer.cornerRadius = 8
        adTitle.backgroundColor = .cyan
    }
    
    func bind(_ title: String) {
        self.adTitle.text = title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
