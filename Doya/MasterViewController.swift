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
    


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.navigationItem.leftBarButtonItem = self.editButtonItem()

//        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
//        self.navigationItem.rightBarButtonItem = addButton
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func insertNewObject(sender: AnyObject) {
        objects.insertObject(DoyaData(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    @IBAction func addImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//        [self presentViewController:imagePicker animated:YES completion:nil];
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            let convertedImage = convertImage(image)
            
            let data = UIImageJPEGRepresentation(convertedImage, 1.0)
            
            let requestURL = NSURL(string: "http://ds-s3-uploader.herokuapp.com/upload")
            let request = NSMutableURLRequest(URL: requestURL)
            request.HTTPMethod = "POST"
            let session = NSURLSession.sharedSession()
            let queue = session.delegateQueue
            let task = session.uploadTaskWithRequest(request, fromData: data) { (resData, response, error) -> Void in
                let res = response as NSHTTPURLResponse
                if res.statusCode == 200{
                    let dataURL = NSString(data: resData, encoding: NSUTF8StringEncoding)
                    print(dataURL)
                    self.pushFileNameToRedis(dataURL)
                }
            }
            task.resume()
            
            queue.waitUntilAllOperationsAreFinished()
            NSThread.sleepForTimeInterval(3)

        }


        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func convertImage(image: UIImage) ->UIImage{
        let scaleImage = convertImageScale(image)
        let dataSizeImage = reduceImageDataSize(scaleImage)

        return dataSizeImage
    }
    
    func convertImageScale(image: UIImage) ->UIImage{
        let width = 600 as CGFloat
        let height = 600 as CGFloat
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1.0)
        image.drawInRect(CGRectMake(0,0,width,height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return newImage
    }
    
    func reduceImageDataSize(image: UIImage) ->UIImage{
        var data : NSData
        var quality = 1.0 as CGFloat
        do {
            quality -= 0.1
            data = UIImageJPEGRepresentation(image, quality)
        } while (data.length < 10000)

        return image
    }
    
    func pushFileNameToRedis(fileURL: NSString) {
        fileURL
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
        if data.point == nil{
            data.point = 0
        }
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

