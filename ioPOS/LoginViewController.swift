//
//  ViewController.swift
//  ioPOS
//
//  Created by Vincent Oliveira on 01/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var loginTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginClick(sender : AnyObject) {
        NSLog("Click: %@ / %@", loginTextField.text, passwordTextField.text)
    }


}

