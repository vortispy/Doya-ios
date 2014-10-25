//
//  MasterViewController.swift
//  Doya
//
//  Created by vortispy on 2014/08/10.
//  Copyright (c) 2014年 vortispy. All rights reserved.
//

import UIKit
let RedisFileScoreSortedSetsKey = "fileScores"
let RedisPointKey = "doyaScores"
let RedisReportKey = "report"
let EVAL_SHA = "665bc81b1e2e84d22625d57b01af037844b9b829"

class MasterViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var objects = NSMutableArray()
    
    
    let userId = UIDevice().identifierForVendor.UUIDString
    
    let agree: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    /* TODO: rename function name */
    var pivot = 0
    func fetch() {
        // no process twice!
        if pivot != 0 {
            return
        }
        pivot = 1
        NSTimer.scheduledTimerWithTimeInterval(10, target: NSBlockOperation(block: { () -> Void in
            self.pivot = 0
        }), selector: "main", userInfo: nil, repeats: false)
        
        NSOperationQueue().addOperationWithBlock {
            if let redis = DSRedis.sharedRedis() {
                let scores = redis.scoresForKey(RedisFileScoreSortedSetsKey, withRange: NSRange(location: 0,  length: 10)) as NSDictionary
                
                let sortedKeys = scores.keysSortedByValueUsingSelector("compare:") as [String]
                
                
                for key in sortedKeys{
                    let doya = DoyaData()
                    doya.url = key
                    doya.point = redis.scoreForKey(RedisPointKey, member: key)
                    self.objects.insertObject(doya, atIndex: 0)
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock { self.tableView.reloadData() }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetch", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
//        NSUserDefaults.standardUserDefaults().removeObjectForKey(Doya.AGREEMENT)
//        NSUserDefaults.standardUserDefaults().synchronize()
        let storyboard = self.storyboard
        let agreement = storyboard?.instantiateViewControllerWithIdentifier("agreement") as UIViewController
        let ok: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(Doya.AGREEMENT)
        if ok == nil {
            self.presentViewController(agreement, animated: true, completion: nil)
        }

    }
    
//    override func dealloc() {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

    @IBAction func addImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            let convertedData = convertImage(image)
            if convertedData == nil{
                self.imageUploadErrorMessageDialog("画像が大きすぎます")
                return
            }
            
            let requestURL = NSURL(string: "http://ds-s3-uploader.herokuapp.com/upload")
            let request = NSMutableURLRequest(URL: requestURL)
            request.HTTPMethod = "POST"
            let session = NSURLSession.sharedSession()
            let queue = session.delegateQueue
            let task = session.uploadTaskWithRequest(request, fromData: convertedData) { (resData, response, error) -> Void in
                if error != nil {
                    self.imageUploadErrorMessageDialog("ネットワークにつないでください")
                    return
                }
                let res = response as NSHTTPURLResponse
                if res.statusCode == 200{
                    let dataURL = NSString(data: resData, encoding: NSUTF8StringEncoding)
                    print(dataURL)
                    if let redisResponse: String? = self.pushFileNameToRedis(dataURL){
                        if redisResponse == "black"{
                            self.imageUploadErrorMessageDialog("YOU ARE IN BLACK LIST")
                        } else{
                            let doya = DoyaData()
                            doya.url = dataURL
                            self.objects.insertObject(doya, atIndex: 0)
                            NSOperationQueue.mainQueue().addOperationWithBlock({ self.tableView.reloadData() })
                        }
                    } else{
                        self.imageUploadErrorMessageDialog("Redis ERROR")
                    }
                } else{
                    let resMessage = NSString(data: resData, encoding: NSUTF8StringEncoding)
                    print("\(res.statusCode): ")
                    print("\(resMessage)\n")
                    self.imageUploadErrorMessageDialog("\(res.statusCode): \(resMessage)")
                }
            }
            task.resume()
            
            queue.waitUntilAllOperationsAreFinished()
        }


        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageUploadErrorMessageDialog(message: String){
        NSOperationQueue.mainQueue().addOperationWithBlock({
            UIAlertView(title: "アップロードに失敗しました",
                message: message,
                delegate: nil,
                cancelButtonTitle: "OK").show();
            return
        })
    }
    
    func convertImage(image: UIImage) -> NSData?{
        let scaleImage = convertImageScale(image)
        let dataSizeImage = reduceImageDataSize(scaleImage)

        return dataSizeImage
    }
    
    let MaxImageSize : CGSize = CGSizeMake(600, 600)
    func convertImageScale(image: UIImage) ->UIImage{
        UIGraphicsBeginImageContextWithOptions(MaxImageSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, MaxImageSize.width, MaxImageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return newImage
    }
    
    
    let MaxImageDataSize = 1048576 // 1024*1024
    let MaxQuality: CGFloat = 1.0
    let MinQuality: CGFloat = 0.5
    func reduceImageDataSize(image: UIImage) -> NSData?{
        var data : NSData
        var quality = MaxQuality as CGFloat
        do {
            data = UIImageJPEGRepresentation(image, quality)
            quality -= 0.1
            if (quality < MinQuality){
                print("reduceImageDataSize: \(quality)\n")
                print("data.length: \(data.length)bytes\n")
                return nil
            }
        } while (data.length > MaxImageDataSize)


        return data
    }

    func pushFileNameToRedis(fileURL: NSString) -> String? {
        let redis = DSRedis.sharedRedis()
        let timeNow = NSDate().timeIntervalSince1970 as NSNumber
        let keys = [userId, fileURL]
        let args = [timeNow.description]
        
        if let ret = redis.evalWithSHA(EVAL_SHA, keys: keys as [AnyObject], args: args) as? String{
            return ret
        }
        return nil
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let data = objects[indexPath.row] as DoyaData

        let cell = tableView.dequeueReusableCellWithIdentifier("DoyaCell", forIndexPath: indexPath) as DoyaCell
        cell.viewController = self
        cell.configureCell(data)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

