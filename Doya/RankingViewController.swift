//
//  RankingViewController.swift
//  Doya
//
//  Created by vortispy on 2014/08/22.
//  Copyright (c) 2014年 vortispy. All rights reserved.
//

import UIKit

class RankingViewController: UITableViewController {
    let rankArray = ["rank01", "rank02", "rank03", "rank04", "rank05", "rank06", "rank07", "rank08", "rank09", "rank10"]
    
    let RedisPointKey = "doyaScores"
    
    var rankingRows: Int?
    
    var urlPath = [String:NSURL]()
    var points = [String:Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let redis = DSRedis.sharedRedis()
        let zdic = redis.scoresForKey(RedisPointKey, withRange: NSRange(location: 0, length: 10)) as Dictionary<String,Int>
        let dic = NSDictionary(dictionary: zdic)
        let sortedKeys = dic.keysSortedByValueUsingComparator({(v1: AnyObject!, v2: AnyObject!) -> NSComparisonResult in
            if v1.integerValue < v2.integerValue{
                return NSComparisonResult.OrderedDescending
            }
            if v1.integerValue > v2.integerValue{
                return NSComparisonResult.OrderedAscending
            }
            return NSComparisonResult.OrderedSame
        })
        
        for var i = 0; i < sortedKeys.endIndex; i += 1{
            let k = sortedKeys[i] as String
            let v = zdic[k]!
            self.points[self.rankArray[i]] = v as Int
            self.urlPath[self.rankArray[i]] = NSURL(string: k)
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return urlPath.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.rankArray[indexPath.row], forIndexPath: indexPath) as RankCell
        let rank = self.rankArray[indexPath.row]
        let point = self.points[rank]
        let url = self.urlPath[rank]
        cell.configureCell(rank, url: url!, point: point!)

        // Configure the cell...

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
