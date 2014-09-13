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

    func configureCell(rank: String, url: NSURL, point: Int){
        self.rankPointLabel.text = rank
        self.rankIcon.image = UIImage(named: rank)
        self.rankPointLabel.text = toString(point)
        
        setAsyncImage(url)
    }
    
    func setAsyncImage(url: NSURL) {
        let queu = NSOperationQueue()
        queu.addOperationWithBlock { () -> Void in
            var data = NSData(contentsOfURL: url)
            var picture = UIImage(data: data)
            self.updatePicture(picture)
        }
    }
    
    func updatePicture(image: UIImage) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.pictureView.image = image
        }
    }
}
