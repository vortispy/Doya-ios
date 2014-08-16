//
//  KuboCell.swift
//  Doya
//
//  Created by vortispy on 2014/08/16.
//  Copyright (c) 2014年 vortispy. All rights reserved.
//

import UIKit

class DoyaCell: UITableViewCell {
    @IBOutlet weak var nankaLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(){
        self.nankaLabel.text = "nanka Label"
        self.subTitleLabel.text = "sub Title yade"
        self.pictureView.image = nil
    }

}
