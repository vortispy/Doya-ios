//
//  KuboCell.swift
//  Doya
//
//  Created by vortispy on 2014/08/16.
//  Copyright (c) 2014年 vortispy. All rights reserved.
//

import UIKit

class DoyaCell: UITableViewCell {
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!
    
    var doya: DoyaData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(data: DoyaData){
        self.doya = data
        self.pointLabel.text = String(self.doya!.point)
        
//        var url = NSURL(string: "http://upload.wikimedia.org/wikipedia/commons/b/bc/Kolkrabe.jpg")

        let url = NSURL(string: data.url)
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
    
    @IBAction func goodDoya(){
        self.doya!.point += 1
        self.pointLabel.text = String(self.doya!.point)
    }
    
    @IBAction func badDoya(){
        self.doya!.point -= 1
        self.pointLabel.text = String(self.doya!.point)
    }
}
