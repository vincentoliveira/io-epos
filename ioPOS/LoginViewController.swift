//
//  ViewController.swift
//  ioPOS
//
//  Created by Vincent Oliveira on 01/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, RestClientProtocol {
    
    @IBOutlet var errorLabel : UILabel!
    @IBOutlet var loginTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appDelegate : AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate);
        var context : NSManagedObjectContext = appDelegate.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "RestaurantToken")
        request.returnsObjectsAsFaults = false
        
        var results:NSArray = context.executeFetchRequest(request, error: nil)!
        
        appDelegate.setRestaurant(nil)
        if results.count > 0 {
            let restaurantToken:NSManagedObject = results[0] as NSManagedObject
            loginTextField.text = restaurantToken.valueForKey("email") as? String
            appDelegate.setRestaurant(restaurantToken.valueForKey("token") as? String)
            
            redirectToPOS()
        }
        
        
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
            var appDeleguage : AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate);
            var context : NSManagedObjectContext = appDeleguage.managedObjectContext!
            
            // Save restaurant token
            var newRestaurantToken = NSEntityDescription.insertNewObjectForEntityForName("RestaurantToken", inManagedObjectContext: context) as NSManagedObject
            newRestaurantToken.setValue(token["token"] as String, forKey: "token")
            newRestaurantToken.setValue(loginTextField.text as String, forKey: "email")
            newRestaurantToken.setValue(passwordTextField.text as String, forKey: "password")
            
            context.save(nil)
            
            redirectToPOS()
        } else {
            errorLabel.text = results["message"] as String!
        }
        
        self.activityIndicatorView.stopAnimating();
    }

    func didFailWithError(error: NSError!) {
        self.activityIndicatorView.stopAnimating();
        errorLabel.text = "Une erreur s'est produite"
    }

    func redirectToPOS() {
        performSegueWithIdentifier("logToPos", sender: self)
    }

}

