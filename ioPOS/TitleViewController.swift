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
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    let cellIdentifier = "OrderCell"
    var timer = NSTimer()
    var items: [NSObject] = [NSObject]()
    var chosen = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidesWhenStopped = true;
        
        detailView.backgroundColor = self.view.backgroundColor
        
        // Praise our lord David DelMonte
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //-------------------------------
        
        self.tableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        self.tableView.registerClass(OrderTableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        //var cellNib = UINib(nibName:"OrderTableViewCell", bundle: nil)
        //self.tableView.registerNib(cellNib, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.rowHeight = 160
        
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
        var cell = OrderTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: self.cellIdentifier)
        cell.setInfo(self.items[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        chosen = indexPath.row
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
        errorLabel.text = "Pas de réseau"
    }
    
    func reloadTableView(){
        var appDeleguage : AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate);
        var context : NSManagedObjectContext = appDeleguage.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Cart")
        var sortDescriptor = NSSortDescriptor(key: "delivery", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let results = context.executeFetchRequest(request, error: nil)
        items.removeAll(keepCapacity: true)
        items = results as [NSObject]
        
        self.tableView.reloadData()
        self.updateViewConstraints()
    }
    
    func validate(){
        println("validate :")
        println(items[chosen].description)
        //ADD WEBSERVICE
    }
    
    func discard(){
        println("discard :")
        println(items[chosen].description)
        //ADD WEBSERVICE
    }
    //------------------------------
    
    
    // MARK: - Detailed view
    func setDetailInfo(o: NSObject) {
        detailView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        for (var subview) in detailView.subviews
        {
            subview.removeFromSuperview()
        }
        let bgc = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        let gray = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        
        let wdth = detailView.frame.size.width
        let hPad: CGFloat = 10 //Horizontal padding
        var y: CGFloat = 5
        
        var name: String = ""
        if (o.valueForKey("client") != nil) {
            if o.valueForKey("client").valueForKey("firstname") != nil {
                name += o.valueForKey("client").valueForKey("firstname").description + " "
            }
            if o.valueForKey("client").valueForKey("lastname") != nil {
                name += o.valueForKey("client").valueForKey("lastname").description
            }
        }
        var nameLbl = UILabel(frame: CGRectMake(120/*TODO*/, y, 300, 42))
        nameLbl.text = name;
        nameLbl.textAlignment = NSTextAlignment.Left
        nameLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
        detailView.addSubview(nameLbl)
        y += nameLbl.frame.height
        
        var id: String = "N°"
        id += o.valueForKey("id").description + "\n"
        id += "Commande ONLINE\n"
        var nstime : NSString = o.valueForKey("delivery").description
        id += (nstime.substringFromIndex(11) as NSString).substringToIndex(5)
        
        var idLbl = UILabel(frame: CGRectMake(120/*TODO*/, y, 300, 63))
        idLbl.text = id;
        idLbl.textColor = gray
        idLbl.textAlignment = NSTextAlignment.Left
        idLbl.numberOfLines = 3
        detailView.addSubview(idLbl)
        y += idLbl.frame.height
        
        y += 5
        var sep1 = UILabel(frame: CGRectMake(hPad, y, wdth - hPad * 2, 1))
        sep1.backgroundColor = gray
        detailView.addSubview(sep1)
        y += 6
        
        var productList = UIScrollView(frame: CGRectMake(hPad, y, wdth - hPad * 2, 450))
        var subY: CGFloat = 0
        var products: NSMutableSet = o.valueForKey("products") as NSMutableSet
        for p in products {
            var pr: NSObject = p as NSObject
            var subNameLbl = UILabel(frame: CGRectMake(hPad, subY, wdth - hPad*4 - 80, 21))
            subNameLbl.text = "1 " + pr.valueForKey("name").description
            subNameLbl.textAlignment = NSTextAlignment.Left
            var subPriceLbl = UILabel(frame: CGRectMake(wdth - 80 - hPad*3, subY, 80, 21))
            subPriceLbl.text = (pr.valueForKey("price") as Float).description + "0€"
            subPriceLbl.textAlignment = NSTextAlignment.Right
            productList.addSubview(subNameLbl)
            productList.addSubview(subPriceLbl)
            subY += subNameLbl.frame.height
            
            if pr.valueForKey("extra") != nil {
                var extraLbl = UILabel(frame: CGRectMake(hPad*3, subY, wdth-hPad*6, 10))
                extraLbl.text = pr.valueForKey("extra").description
                extraLbl.textAlignment = NSTextAlignment.Left
                extraLbl.font = UIFont(name: "HelveticaNeue", size: 11)
                productList.addSubview(extraLbl)
                subY += extraLbl.frame.height
            }
            
            subY += 5
        }
        var size: CGSize = productList.frame.size
        size.height = subY
        productList.contentSize = size
        detailView.addSubview(productList)
        y += productList.frame.size.height
        
        y += 5
        var sep2 = UILabel(frame: CGRectMake(hPad, y, wdth - hPad*2, 1))
        sep2.backgroundColor = gray
        detailView.addSubview(sep2)
        y += 6
        
        var totalTTC = UILabel(frame: CGRectMake(hPad, y + 14, wdth - 150 - hPad*2, 16))
        totalTTC.text = "Total";
        totalTTC.textAlignment = NSTextAlignment.Right
        totalTTC.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        detailView.addSubview(totalTTC)
        
        var price: String = (o.valueForKey("total") as Float).description
        price += "0€"
        var priceLbl = UILabel(frame: CGRectMake(wdth - 150 - hPad, y, 150, 30))
        priceLbl.text = price;
        priceLbl.textAlignment = NSTextAlignment.Right
        priceLbl.font = UIFont(name: "HelveticaNeue", size: 30)
        detailView.addSubview(priceLbl)
        y += priceLbl.frame.size.height + 4
        
        //------------BUTTONS
        let txtWhite = UIColor(white: 1, alpha: 0.8)
        y += hPad
        var discardB = UIButton(frame: CGRectMake(hPad, y, 80, 50))
        discardB.backgroundColor = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
        discardB.setTitle("x", forState: UIControlState.Normal)
        discardB.setTitleColor(txtWhite, forState: UIControlState.Normal)
        discardB.addTarget(self, action: "discard", forControlEvents: UIControlEvents.TouchDown)
        detailView.addSubview(discardB)
        
        var validateB = UIButton(frame: CGRectMake(80 + 2*hPad, y, detailView.frame.size.width - 80 - 3*hPad, 50))
        validateB.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0.2, alpha: 1)
        validateB.setTitle("V", forState: UIControlState.Normal)
        validateB.setTitleColor(txtWhite, forState: UIControlState.Normal)
        validateB.addTarget(self, action: "validate", forControlEvents: UIControlEvents.TouchDown)
        detailView.addSubview(validateB)
        y += hPad + validateB.frame.size.height
        //-------------------
    }

}
