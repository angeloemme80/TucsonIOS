//
//  HyundaiTucsonItalia.swift
//  Tucson
//
//  Created by Angela Mac on 13/11/2016.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class HyundaiTucsonItalia: BaseViewController {
    
    
    @IBOutlet weak var bottoneUnisciti: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.title = NSLocalizedString("hyundai_tucson_italia", comment:"")
        bottoneUnisciti.setTitle(NSLocalizedString("join", comment:""), for: .normal) ;
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unisciti_button(_ sender: Any) {
        print("click su unisciti a noi")
        UIApplication.tryURL(urls: [
            "fb://group/1690004191213452", // App
            "https://www.facebook.com/groups/hyundai.tucson.club.italia/" // Website if app fails
            ])
    }
    
    
    
    // MARK: - Navigation
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }*/
    
    
}

extension UIApplication {
    class func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(NSURL(string: url)! as URL) {
                application.openURL(NSURL(string: url)! as URL)
                return
            }
        }
    }
}
