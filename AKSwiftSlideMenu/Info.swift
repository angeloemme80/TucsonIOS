//
//  Info.swift
//  Tucson
//
//  Created by Angela Mac on 13/11/2016.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class Info: BaseViewController {
    
    @IBOutlet weak var textInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.title = NSLocalizedString("app_info", comment:"")        
        let attrStr = try! NSAttributedString(
            data: NSLocalizedString("info_text", comment:"").data(using: String.Encoding.unicode, allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        textInfo.attributedText = attrStr
        
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
