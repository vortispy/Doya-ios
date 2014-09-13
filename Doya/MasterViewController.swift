//
//  MasterViewController.swift
//  Doya
//
//  Created by vortispy on 2014/08/10.
//  Copyright (c) 2014年 vortispy. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var objects = NSMutableArray()
    
    let RedisFileScoreSortedSetsKey = "fileScores"
    let RedisPointKey = "pictures"

    var RedisHost: NSString?
    var RedisPort: NSNumber?
    var RedisPass: NSString?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSBundle.mainBundle().URLForResource("secrets", withExtension: "plist");
        let dict = NSDictionary(contentsOfURL: url!);
        print(dict["redis-host"])
        RedisHost = dict["redis-host"] as? NSString
        RedisPort = dict["redis-port"] as? NSNumber
        RedisPass = dict["redis-pass"] as? NSString

        var h = dict["redis-host"] as? NSString
        var o = dict["redis-port"] as? NSNumber
        var a = dict["redis-pass"] as? NSString
        let redis = DSRedis(server: RedisHost, port: RedisPort!, password: RedisPass)
//        let redis = DSRedis(server: "localhost", port: 6379, password: nil)
        let scores = redis.scoresForKey(RedisPointKey, withRange: NSRange(location: 0, length: 10))
        let dicScores = NSDictionary(dictionary: scores)
        let sortedKeys = dicScores.keysSortedByValueUsingComparator({(v1: AnyObject!, v2: AnyObject!) -> NSComparisonResult in
            if v1.integerValue > v2.integerValue{
                return NSComparisonResult.OrderedDescending
            }
            if v1.integerValue < v2.integerValue{
                return NSComparisonResult.OrderedAscending
            }
            return NSComparisonResult.OrderedSame
        })
        for key in sortedKeys{
                let k = "\(key)"
                let v = (scores[key as NSObject]! as NSString).integerValue
                let doya = DoyaData()
                doya.point = v
                doya.url = k
                objects.insertObject(doya, atIndex: 0)
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    let redisResponse: AnyObject? = self.pushFileNameToRedis(dataURL)
                    if redisResponse == nil{
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

    func pushFileNameToRedis(fileURL: NSString) -> AnyObject? {
        let redis = DSRedis(server:"localhost", port:6379, password: nil)
        let timeNow = NSDate().timeIntervalSince1970 as NSNumber
        if let ret: AnyObject = redis.addValue(fileURL, withScore: timeNow, forKey: RedisFileScoreSortedSetsKey){
        } else{
            print("Redis ZADD failed: key=\(RedisFileScoreSortedSetsKey), member=\(fileURL), score=\(timeNow)")
            return nil
        }
        
        if let ret2: AnyObject = redis.addValue(fileURL, withScore: 0, forKey: RedisPointKey){
            return ret2
        } else{
            print("Redis ZADD failed: key=\(RedisPointKey), member=\(fileURL), score=\(0)")
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

