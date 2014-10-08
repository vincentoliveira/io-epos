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
    
    @IBOutlet weak var detailView: OrderView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    let cellIdentifier = "OrderCell"
    var timer = NSTimer()
    var items: [NSObject] = [NSObject]()
    var chosen: Int = -1
    var chosen_id = ""
    var restaurant = "NormanWordpress"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true;
        
        detailView.backgroundColor = view.backgroundColor
        detailView.restaurant = restaurant
        detailView.parent = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        tableView.registerClass(OrderTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = 140
        
        reloadTableView()
        loadOrders()
        let aSelector: Selector = "loadOrders"
        
        timer = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: aSelector, userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Tableview functions
    func tableView(tableView: UITableView, numberOfRowsInSection section:    Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //var cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as OrderTableViewCell
        var cell = OrderTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        cell.restaurant = restaurant
        cell.parent = self
        cell.setInfo(items[indexPath.row])
        /*if (items[indexPath.row].valueForKey("status").description == "INIT") {
            cell.hidden = true
        }*/
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        chosen = indexPath.row
        chosen_id = items[chosen].valueForKey("id").description
        clearDetailInfo()
        setDetailInfo(items[chosen])
    }
    //------------------------------

    
    // MARK: - Webservice
    func loadOrders() {
        println("Reload orders")
        errorLabel.text = nil
        self.activityIndicatorView.startAnimating();
        
        let restClient = RestClient()
        restClient.delegate = self;
        restClient.getOrders(restaurant);
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
            let identity = client["identity"] as NSDictionary
            var newClient = NSEntityDescription.insertNewObjectForEntityForName("Client", inManagedObjectContext: context) as NSManagedObject
            newClient.setValue(client["id"] as Int, forKey: "id")
            newClient.setValue(client["username"], forKey: "username")
            newClient.setValue(identity["firstname"], forKey: "firstname")
            newClient.setValue(identity["lastname"], forKey: "lastname")
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
            var totalTVA: Float = 0
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
                newProduct.setValue(product["vat"] as Float, forKey: "tva")
                var price: Float = product["price"] as Float
                var tva: Float = product["vat"] as Float
                totalTVA += (tva * price) / 100.0
                newProduct.setValue(product["price"] as Float, forKey: "price")
                newProduct.setValue(1, forKey: "number");
                newProduct.setValue(newCart, forKey: "cart");
                
                //fetch product
                var found = false
                for p in products {
                    if (p.valueForKey("id") as Int) == (newProduct.valueForKey("id") as Int) && (p.valueForKey("extra") as String? == newProduct.valueForKey("extra") as String?) {
                        var n = 1
                        if var nn = p.valueForKey("number") as? Int {
                            n = nn
                        }
                        p.setValue(n + 1, forKey: "number")
                        found = true
                        break
                    }
                }
                if !found {
                    products.addObject(newProduct)
                }
            }
            newCart.setValue(products, forKey: "products")
            newCart.setValue(totalTVA, forKey: "total_tva")
            //---------------
        }
        context.save(nil)
        reloadTableView()
        self.activityIndicatorView.stopAnimating();
    }
    
    func didFailWithError(error: NSError!) {
        self.activityIndicatorView.stopAnimating();
        errorLabel.text = "Pas de réseau"
    }
    
    func reloadTableView(){
        var appDeleguage : AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate);
        var context : NSManagedObjectContext = appDeleguage.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Cart")
        var timeDescriptor = NSSortDescriptor(key: "delivery", ascending: true)
        var statusDescriptor = NSSortDescriptor(key: "status", ascending: true)
        request.sortDescriptors = [statusDescriptor, timeDescriptor]
        
        let results = context.executeFetchRequest(request, error: nil)
        
        resetItemsList(results)
        
        tableView.reloadData()
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: chosen, inSection: 0))?.setSelected(true, animated: false)
        updateViewConstraints()
    }
    
    func resetItemsList(results: [AnyObject]?){
        items.removeAll(keepCapacity: true)
        items = results as [NSObject]
        
        if chosen > -1 {
            clearDetailInfo()
            chosen = -1
            for (var i = items.count-1; i >= 0; i--) {
                var id: AnyObject? = items[i].valueForKey("id")
                if id != nil && id!.description == chosen_id {
                    chosen = i
                    setDetailInfo(items[chosen])
                    break
                }
            }
        }
    }
    //------------------------------
    
    
    // MARK: - Detailed view
    func clearDetailInfo(){
        detailView.backgroundColor = view.backgroundColor
        for (var subview) in detailView.subviews {
            subview.removeFromSuperview()
        } //CLEAN
    }
    func setDetailInfo(o: NSObject) {
        detailView.source = o
        detailView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        detailView.setDetailInfo()
    }
}
