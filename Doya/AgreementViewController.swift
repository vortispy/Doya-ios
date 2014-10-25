//
//  AgreementViewController.swift
//  Doya
//
//  Created by vortispy on 2014/10/25.
//  Copyright (c) 2014年 vortispy. All rights reserved.
//

import UIKit

let AGREEMENT = "agreement"
class AgreementViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func agree() {
        let userData = NSUserDefaults.standardUserDefaults()
        userData.setObject(1, forKey: AGREEMENT)
        userData.synchronize()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
