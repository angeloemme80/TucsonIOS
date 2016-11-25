//
//  Impostazioni.swift
//  Tucson
//
//  Created by Angela Mac on 13/11/2016.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class Impostazioni: BaseViewController {
    
    
    @IBOutlet weak var lblInviaMail: UILabel!
    @IBOutlet weak var switchMail: UISwitch!
    @IBOutlet weak var lblInviaAnonima: UILabel!
    @IBOutlet weak var switchAnonima: UISwitch!
    @IBOutlet weak var lblStorico: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.title = NSLocalizedString("settings", comment:"")
        lblInviaMail.text = NSLocalizedString("allow_view_email", comment:"")
        lblInviaMail.textAlignment = NSTextAlignment.center
        lblInviaAnonima.text = NSLocalizedString("send_anonymous", comment:"")
        lblInviaAnonima.textAlignment = NSTextAlignment.center
        lblStorico.text = NSLocalizedString("max_historical_positions", comment:"")
        lblStorico.textAlignment = NSTextAlignment.center

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
