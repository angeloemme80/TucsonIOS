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
    @IBOutlet weak var sliderStorico: UISlider!
    @IBOutlet weak var lblValoreStorico: UILabel!
    
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

        let preferencesImpostazioni = UserDefaults.init(suiteName: nomePreferenceImpostazioni)
        let valueSwitchEmail = preferencesImpostazioni?.bool(forKey: "switchEmail")
        let valueSwitchAnonimo = preferencesImpostazioni?.bool(forKey: "switchAnonimo")
        let slider = preferencesImpostazioni?.float(forKey: "slider")
        switchMail.setOn(valueSwitchEmail!, animated: true)
        switchAnonima.setOn(valueSwitchAnonimo!, animated: true)
        sliderStorico.setValue(slider!, animated: true)
        lblValoreStorico.text =  String(format:"%.0f", sliderStorico.value)
    }
    
    @IBAction func switchMailClick(_ sender: Any) {
        let preferencesImpostazioni = UserDefaults.init(suiteName: nomePreferenceImpostazioni)
        preferencesImpostazioni?.set(switchMail.isOn, forKey: "switchEmail")
    }
    
    @IBAction func switchAnonimaClick(_ sender: Any) {
        let preferencesImpostazioni = UserDefaults.init(suiteName: nomePreferenceImpostazioni)
        preferencesImpostazioni?.set(switchAnonima.isOn, forKey: "switchAnonimo")
    }
    
    @IBAction func sliderValueChange(_ sender: Any) {
        let preferencesImpostazioni = UserDefaults.init(suiteName: nomePreferenceImpostazioni)
        //preferencesImpostazioni?.set(sliderStorico.value, forKey: "slider")
        preferencesImpostazioni?.set(String(format:"%.0f", sliderStorico.value), forKey: "slider")
        lblValoreStorico.text =  String(format:"%.0f", sliderStorico.value)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
