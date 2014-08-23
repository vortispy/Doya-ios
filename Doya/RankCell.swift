//
//  RankCell.swift
//  Doya
//
//  Created by vortispy on 2014/08/22.
//  Copyright (c) 2014年 vortispy. All rights reserved.
//

import UIKit

class RankCell: UITableViewCell {
    @IBOutlet weak var rankPointLabel: UILabel!
    @IBOutlet weak var rankIcon: UIImageView!
    @IBOutlet weak var pictureView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(rank: String){
        self.rankPointLabel.text = rank
        self.rankIcon.image = UIImage(named: rank)
        
    }
}
