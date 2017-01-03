//
//  Info.swift
//  Tucson
//
//  Created by Angela Mac on 13/11/2016.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class Info: BaseViewController {
    
    
    @IBOutlet weak var info: UITextView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.title = NSLocalizedString("app_info", comment:"")
        
        info.text = NSLocalizedString("info_text_01", comment:"") + "\n"
         + "\n" + NSLocalizedString("info_text_02", comment:"") + "\n"
         + "\n" + NSLocalizedString("info_text_03", comment:"") + "\n"
         + "\n" + NSLocalizedString("info_text_04", comment:"") + "\n"
         + "\n" + NSLocalizedString("info_text_05", comment:"") + "\n"
         + "\n" + NSLocalizedString("info_text_06", comment:"") + "\n"
         + "\n" + NSLocalizedString("info_text_07", comment:"")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension NSMutableAttributedString {
    
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSLinkAttributeName, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}
