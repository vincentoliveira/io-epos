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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    let cellIdentifier = "OrderCell"
    var items: [NSObject] = [NSObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidesWhenStopped = true;
        
        // Praise our lord David DelMonte
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //-------------------------------
        
        self.tableView.registerClass(OrderTableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        loadOrders()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Tableview functions
    func tableView(tableView: UITableView, numberOfRowsInSection section:    Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as OrderTableViewCell
        
        cell.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        cell.textLabel?.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        var id = self.items[indexPath.row].valueForKey("id").description
        cell.idLabel = UILabel()
        cell.idLabel?.text = "N° \(id)"
        
        var price:String = (self.items[indexPath.row].valueForKey("total") as Float).description
        if (self.items[indexPath.row].valueForKey("total_unpayed") as Float != 0) {
            price += "€ UNPAYED "
        } else {
            price += "€ PAYED "
        }
        cell.priceLabel?.text = price
        //cell.textLabel?.text = id
        //cell.detailTextLabel?.text = label
        
        if cell.priceLabel == nil {
            println("fuck it")
        }
        
        return cell
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println("You selected cell #\(indexPath.row)!")
    }
    //------------------------------

    
    func loadOrders() {
        errorLabel.text = nil
        self.activityIndicatorView.startAnimating();
        
        let restClient = RestClient()
        restClient.delegate = self;
        restClient.getOrders("NormanWordpress");
    }
    
    func didRecieveResponse(results: NSDictionary) {
        var appDeleguage : AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate);
        var context : NSManagedObjectContext = appDeleguage.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Cart")
        var previous = context.executeFetchRequest(request, error: nil)
        var oldOrdersArray = previous as [NSManagedObject]
        for order:NSManagedObject in oldOrdersArray {
            context.deleteObject(order)
        }
        
        let ordersArray = results["orders"] as NSArray;
        for order in ordersArray {
            // Parse orders
            var newCart = NSEntityDescription.insertNewObjectForEntityForName("Cart", inManagedObjectContext: context) as NSManagedObject
            
            // Parse client
            let client = order["client"] as NSDictionary
            var newClient = NSEntityDescription.insertNewObjectForEntityForName("Client", inManagedObjectContext: context) as NSManagedObject
            newClient.setValue(client["id"] as Int, forKey: "id")
            newClient.setValue(client["username"], forKey: "username")
            newClient.setValue(client["firstname"], forKey: "firstname")
            newClient.setValue(client["lastname"], forKey: "lastname")
            newClient.setValue(newCart, forKey: "order")
            
            newCart.setValue(newClient, forKey: "client")
            //--------------
            
            let delivery = order["delivery_date"] as NSDictionary
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
            let date = dateFormatter.dateFromString(delivery["date"] as String)
            newCart.setValue(date, forKey: "delivery")
            
            newCart.setValue(order["id"] as Int, forKey: "id")
            newCart.setValue(order["status"] as String, forKey: "status")
            newCart.setValue(order["total"] as Float, forKey: "total")
            newCart.setValue(order["total_unpayed"] as Float, forKey: "total_unpayed")
            
            // Parse products
            var products: NSMutableSet = NSMutableSet()
            let productsArray = order["products"] as NSArray;
            for product in productsArray {
                var newProduct = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as NSManagedObject
                
                newProduct.setValue(product["product_id"] as Int, forKey: "id")
                newProduct.setValue(product["name"], forKey: "name")
                newProduct.setValue(product["short_name"], forKey: "short_name")
                
                if  product["extra"] is NSString {
                    newProduct.setValue(product["extra"], forKey: "extra")
                }
                newProduct.setValue(product["vat"] as Float, forKey: "vat")
                newProduct.setValue(product["price"] as Float, forKey: "price")
                newProduct.setValue(newCart, forKey: "cart");
                
                products.addObject(newProduct)
            }
            newCart.setValue(products, forKey: "products")
            //---------------
        }
        context.save(nil)
        reloadTableView()
        self.activityIndicatorView.stopAnimating();
    }
    
    func didFailWithError(error: NSError!) {
        self.activityIndicatorView.stopAnimating();
        errorLabel.text = "Une erreur s'est produite"
    }
    
    func reloadTableView(){
        var appDeleguage : AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate);
        var context : NSManagedObjectContext = appDeleguage.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Cart")
        var sortDescriptor = NSSortDescriptor(key: "delivery", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let results = context.executeFetchRequest(request, error: nil)
        items = results as [NSObject]
        
        self.tableView.reloadData()
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
