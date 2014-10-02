//
//  ViewController.swift
//  ioPOS
//
//  Created by Vincent Oliveira on 01/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, RestClientProtocol {
    
    @IBOutlet var errorLabel : UILabel!
    @IBOutlet var loginTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginClick(sender : AnyObject) {
        errorLabel.text = nil
        self.activityIndicatorView.startAnimating();
        
        let restClient = RestClient()
        restClient.delegate = self;
        restClient.checkAuth(loginTextField.text, password: passwordTextField.text)
    }
    
    func didRecieveResponse(results: NSDictionary) {
        // Store the results in our table data array
        println(results)
        
        if let token: NSDictionary = results["restaurant_token"] as? NSDictionary {
            errorLabel.text = token["token"] as String!
        } else {
            errorLabel.text = results["message"] as String!
        }
        
        self.activityIndicatorView.stopAnimating();
    }

    func didFailWithError(error: NSError!) {
        self.activityIndicatorView.stopAnimating();
        errorLabel.text = "Une erreur s'est produite"
    }


}

