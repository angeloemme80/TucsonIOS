//
//  LoginSignin.swift
//  Tucson
//
//  Created by Angela Mac on 26/01/2017.
//  Copyright © 2017 Kode. All rights reserved.
//

import Foundation
import UIKit

class LoginSignin: BaseViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonSignin: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        
        
        username.placeholder = NSLocalizedString("username", comment:"")
        password.placeholder = NSLocalizedString("password", comment:"")
        email.placeholder = NSLocalizedString("email", comment:"")
        buttonLogin.setTitle(NSLocalizedString("login", comment:""),for: .normal)
        buttonSignin.setTitle(NSLocalizedString("signin", comment:""),for: .normal)
        
        //Intercetto se l'utente ha clikkato su login oppure signin e in base a ciò faccio vedere i campi opportuni
        if appDelegate.clickLoginSignin == "login" {
            self.title = NSLocalizedString("login", comment:"")
            buttonSignin.isHidden = true
            email.isHidden = true
        } else if appDelegate.clickLoginSignin == "signin" {
            self.title = NSLocalizedString("signin", comment:"")
            buttonLogin.isHidden = true
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
