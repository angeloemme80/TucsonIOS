//
//  Info.swift
//  Tucson
//
//  Created by Angela Mac on 13/11/2016.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class Info: BaseViewController {
    
    
    @IBOutlet weak var info01: UILabel!
    @IBOutlet weak var info02: UILabel!
    @IBOutlet weak var info03: UILabel!
    @IBOutlet weak var info04: UILabel!
    @IBOutlet weak var info05: UILabel!
    @IBOutlet weak var info06: UILabel!
    @IBOutlet weak var info07: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.title = NSLocalizedString("app_info", comment:"")        

        info01.text = NSLocalizedString("info_text_01", comment:"")
        info02.text = NSLocalizedString("info_text_02", comment:"")
        info03.text = NSLocalizedString("info_text_03", comment:"")
        info04.text = NSLocalizedString("info_text_04", comment:"")
        info05.text = NSLocalizedString("info_text_05", comment:"")
        info06.text = NSLocalizedString("info_text_06", comment:"")
        info07.text = NSLocalizedString("info_text_07", comment:"")
        
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
