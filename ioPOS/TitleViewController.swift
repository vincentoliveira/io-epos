//
//  TitleViewController.swift
//  ioPOS
//
//  Created by Louis on 02/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit
import CoreData

class TitleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RestClientProtocol {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadOrders()
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidesWhenStopped = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:    Int) -> Int {
        println("10 rows")
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        
        println("Row")
        cell.textLabel?.text = "Row #\(indexPath.row)"
        cell.detailTextLabel?.text = "Subtitle #\(indexPath.row)"
        
        return cell
    }
    
    func loadOrders() {
        errorLabel.text = nil
        self.activityIndicatorView.startAnimating();
        
        let restClient = RestClient()
        restClient.delegate = self;
        restClient.getOrders("NormanWordpress");
    }
    
    func didRecieveResponse(results: NSDictionary) {
        // Store the results in our table data array
        //println(results)
        
        var appDeleguage : AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate);
        var context : NSManagedObjectContext = appDeleguage.managedObjectContext!
        
        let ordersArray = results["orders"] as NSArray;
        for order in ordersArray {
            // Save orders
            var newCart = NSEntityDescription.insertNewObjectForEntityForName("Cart", inManagedObjectContext: context) as NSManagedObject
            
            let client = order["client"] as NSDictionary
            newCart.setValue(client["id"] as Int, forKey: "clientId")
            
            let delivery = order["delivery_date"] as NSDictionary
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-mm-dd' 'HH:mm:ss"
            let date = dateFormatter.dateFromString(delivery["date"] as String)
            newCart.setValue(date, forKey: "delivery")
            
            newCart.setValue(order["id"] as Int, forKey: "id")
            newCart.setValue(order["status"] as String, forKey: "status")
            newCart.setValue(order["total"] as Float, forKey: "total")
            newCart.setValue(order["total_unpayed"] as Float, forKey: "total_unpayed")
            println("New Cart: " + newCart.description)
        }
        context.save(nil)
        
        self.activityIndicatorView.stopAnimating();
    }
    
    func didFailWithError(error: NSError!) {
        self.activityIndicatorView.stopAnimating();
        errorLabel.text = "Une erreur s'est produite"
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
