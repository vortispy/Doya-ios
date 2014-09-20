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
    
    let RedisPointKey = "doyaScores"
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
        if let ret: AnyObject = zincrby(1){
            self.doya!.point += 1
            self.pointLabel.text = String(self.doya!.point)
        }
    }
    
    @IBAction func badDoya(){
        if let ret: AnyObject = zincrby(-1){
            self.doya!.point -= 1
            self.pointLabel.text = String(self.doya!.point)
        }
    }
    
    func zincrby(increment: Int) -> AnyObject?{
        let redis = DSRedis.sharedRedis()
        if let ret = redis.incrementObject(doya!.url, score: increment, forKey: RedisPointKey){
            return ret
        } else{
            print("Redis ZINCRBY failed")
        }
        return nil
    }
}
