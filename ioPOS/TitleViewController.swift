//
//  TitleViewController.swift
//  ioPOS
//
//  Created by Louis on 02/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit
import CoreData

class TitleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, RestClientProtocol {
    
    // MARK: - Attributes
    @IBOutlet weak var filterBar: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var menuBar: UIView!
    @IBOutlet weak var detailView: OrderView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    
    let cellIdentifier = "OrderCell"
    var timer = NSTimer()
    var items = [NSObject]()
    var selectedItems = [NSObject]()
    var filteredItems = [NSObject]()
    var chosen: Int = -1
    var chosen_id = ""
    var restaurant = ""
    var filter = "All"
    var searchtext = ""
    
    // MARK: - Simili-constructor
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.16, green: 0.18, blue: 0.19, alpha: 1)
        setRestaurant()
        initOutlets()
        setFilters()
        
        reloadTableView()
        loadOrders()
        let aSelector: Selector = "loadOrders"
        
        timer = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: aSelector, userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Initialization
    func setRestaurant(){
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        restaurant = appDelegate.getRestaurant()!
    }
    
    func initOutlets(){
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true;
        
        detailView.backgroundColor = view.backgroundColor
        detailView.restaurant = restaurant
        detailView.parent = self
        
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        tableView.registerClass(OrderTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = 140
        
        menuBar.backgroundColor = UIColor(red: 0.21, green: 0.235, blue: 0.26, alpha: 1)
        
        reloadButton.frame = activityIndicatorView.frame
        let aSelector: Selector = "loadOrders"
        reloadButton.addTarget(self, action: aSelector, forControlEvents: UIControlEvents.TouchUpInside)
        var buttonimg = UIImageView(frame: CGRectMake(0, 0, reloadButton.frame.width, reloadButton.frame.height))
        buttonimg.image = UIImage(named: "Icone_Ellipse-Green.png")
        reloadButton.addSubview(buttonimg)
        
        addShadows()
    }
    
    func addShadows(){
        menuBar.layer.shadowColor = UIColor.blackColor().CGColor
        menuBar.layer.shadowOpacity = 1
        menuBar.layer.shadowRadius = 10
        filterBar.layer.shadowColor = UIColor.blackColor().CGColor
        filterBar.layer.shadowOpacity = 1
        filterBar.layer.shadowRadius = 10
    }
    
    func setFilters(){
        addFilter("All", index: 0)
        addFilter("New", index: 1)
        addFilter("InProgress", index: 2)
        addFilter("NoPay", index: 3)
        addFilter("Done", index: 4)
        addFilter("History", index: 5)
    }
    
    func addFilter(title: String, index: CGFloat) {
        let h = filterBar.frame.height / 6
        var filter: FilterButton = FilterButton(frame: CGRectMake(0, h * index, filterBar.frame.width, h))
        filter.parent = self
        filter.initialize(title)
        filterBar.addSubview(filter)
    }
    
    
    // MARK: - Search functions
    func filterContentForSearchText(searchText: String) {
        self.searchtext = searchText
        filteredItems = selectedItems.filter({( cart: NSObject) -> Bool in
            if (searchText == "") { return true }
            var nstime : NSString = cart.valueForKey("delivery") != nil ? cart.valueForKey("delivery").description : "                  "
            var searchField: String = cart.valueForKey("id") != nil ? cart.valueForKey("id").description + " " : ""
            searchField += (cart.valueForKey("total") != nil) ? NSString(format: "%.02f", locale: nil, cart.valueForKey("total") as Float) + "€ " : ""
            searchField += cart.valueForKey("client") != nil && cart.valueForKey("client").valueForKey("lastname") != nil ? cart.valueForKey("client").valueForKey("lastname").description + " " : ""
            searchField += cart.valueForKey("client") != nil && cart.valueForKey("client").valueForKey("firstname") != nil ? cart.valueForKey("client").valueForKey("firstname").description + " " : ""
            searchField += cart.valueForKey("source") != nil ? cart.valueForKey("source").description + " " : ""
            searchField += (nstime.substringFromIndex(11) as NSString).substringToIndex(5)
            let match = searchField.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)?
            return (match != nil)
        })
        chooseAgain()
    }
    
    func searchBar(_searchBar: UISearchBar,
        textDidChange searchText: String) {
            self.filterContentForSearchText(searchText)
            tableView.reloadData()
            tableView.cellForRowAtIndexPath(NSIndexPath(forRow: chosen, inSection: 0))?.setHighlighted(true, animated: false)
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        tableView.reloadData()
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        tableView.reloadData()
        return true
    }
    
    
    // MARK: - Tableview functions
    func tableView(tableView: UITableView, numberOfRowsInSection section:    Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //var cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as OrderTableViewCell
        
        var cell = OrderTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        cell.restaurant = restaurant
        cell.parent = self
        cell.darkDarkGray = view.backgroundColor!
        
        cell.setInfo(filteredItems[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: chosen, inSection: 0))?.setHighlighted(false, animated: false)
        if chosen != indexPath.row {
            chosen = indexPath.row
            if (filteredItems[chosen].valueForKey("id") != nil) {
                chosen_id = filteredItems[chosen].valueForKey("id").description
                clearDetailInfo()
                setDetailInfo(filteredItems[chosen])
                tableView.cellForRowAtIndexPath(indexPath)?.setHighlighted(true, animated: false)
            }
        } else {
            chosen = -1
            clearDetailInfo()
            chosen_id = ""
            tableView.cellForRowAtIndexPath(indexPath)?.setHighlighted(false, animated: false)
        }
    }

    
    // MARK: - Webservice & reload function
    func loadOrders() {
        print("Reload orders -> ")
        errorLabel.text = nil
        self.activityIndicatorView.startAnimating();
        reloadButton.hidden = true;
        
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
        for order:NSManagedObject in oldOrdersArray { context.deleteObject(order) }
        
        if (results["orders"]) != nil {
            let ordersArray = results["orders"] as NSArray;
            for order in ordersArray { parseOrder(order, context: context) }
            context.save(nil)
        } else {
            errorLabel.text = "Token périmé. Reconnectez-vous."
        }
        
        reloadTableView()
        self.activityIndicatorView.stopAnimating()
        reloadButton.hidden = false
    }
    
    func didFailWithError(error: NSError!) {
        self.activityIndicatorView.stopAnimating()
        reloadButton.hidden = false
        errorLabel.text = "Pas de réseau"
    }
    
    func reloadTableView(){
        var appDeleguage : AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate);
        var context : NSManagedObjectContext = appDeleguage.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Cart")
        var timeDescriptor = NSSortDescriptor(key: "delivery", ascending: true)
        var statusDescriptor = NSSortDescriptor(key: "status", ascending: true)
        var idDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [statusDescriptor, timeDescriptor, idDescriptor]
        
        resetItemsList(context.executeFetchRequest(request, error: nil))
        
        tableView.reloadData()
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: chosen, inSection: 0))?.setHighlighted(true, animated: false)
        updateViewConstraints()
    }
    
    func resetItemsList(results: [AnyObject]?){
        items.removeAll(keepCapacity: true)
        items = results as [NSObject]
        applyFilter()
        filterContentForSearchText(searchtext)
    }
    
    func chooseAgain() {
        if chosen > -1 {
            clearDetailInfo()
            chosen = -1
            for (var i = filteredItems.count-1; i >= 0; i--) {
                var id: AnyObject? = filteredItems[i].valueForKey("id")
                if id != nil && id!.description == chosen_id {
                    chosen = i
                    setDetailInfo(filteredItems[chosen])
                    break
                }
            }
        }
    }
    
    
    // MARK: - Parse functions
    func parseOrder(order: AnyObject, context: NSManagedObjectContext) {
        var newCart = NSEntityDescription.insertNewObjectForEntityForName("Cart", inManagedObjectContext: context) as NSManagedObject
        
        newCart = parseClientInfo(order, newCart: newCart, context: context)
        newCart = parseOrderInfo(order, newCart: newCart)
        
        newCart = parseProducts(order, newCart: newCart, context: context)
    }
    
    func parseClientInfo(order: AnyObject, newCart: NSManagedObject, context: NSManagedObjectContext) -> NSManagedObject {
        let client = order["client"] as NSDictionary
        let identity = client["identity"] as NSDictionary
        var newClient = NSEntityDescription.insertNewObjectForEntityForName("Client",
            inManagedObjectContext: context) as NSManagedObject
        newClient.setValue(client["id"] as Int, forKey: "id")
        newClient.setValue(client["username"], forKey: "username")
        newClient.setValue(identity["firstname"], forKey: "firstname")
        newClient.setValue(identity["lastname"], forKey: "lastname")
        if (identity["email"] is NSString) { newClient.setValue(identity["email"], forKey: "email") }
        if (identity["phone1"] is NSDictionary) {
            var phone = identity["phone1"]!.valueForKey("prefix")!.description + identity["phone1"]!.valueForKey("number")!.description
            newClient.setValue(phone, forKey: "phone1")
        }
        if (identity["phone2"] is NSDictionary) {
            var phone = identity["phone2"]!.valueForKey("prefix")!.description + identity["phone2"]!.valueForKey("number")!.description
            newClient.setValue(phone, forKey: "phone2")
        }
        newClient.setValue(newCart, forKey: "order")
        
        newCart.setValue(newClient, forKey: "client")
        return newCart
    }
    
    func parseOrderInfo(order: AnyObject, newCart: NSManagedObject) -> NSManagedObject {
        let delivery = order["delivery_date"] as NSDictionary
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        let date = dateFormatter.dateFromString(delivery["date"] as String)
        newCart.setValue(date, forKey: "delivery")
        
        newCart.setValue(order["id"] as Int, forKey: "id")
        newCart.setValue(order["status"] as String, forKey: "status")
        newCart.setValue(order["source"] as String, forKey: "source")
        newCart.setValue(order["total"] as Float, forKey: "total")
        newCart.setValue(order["total_unpayed"] as Float, forKey: "total_unpayed")
        
        return newCart
    }
    
    func parseProducts(order: AnyObject, newCart: NSManagedObject, context: NSManagedObjectContext) -> NSManagedObject {
        var totalTVA: Float = 0
        var products: NSMutableSet = NSMutableSet()
        let productsArray = order["products"] as NSArray;
        for product in productsArray {
            var newProduct = parseProduct(product, newCart: newCart, context: context)
            
            products = addProduct(products, newProduct: newProduct)
            
            var price: Float = product["price"] as Float
            var tva: Float = product["vat"] as Float
            totalTVA += (tva * price) / 100.0
        }
        newCart.setValue(products, forKey: "products")
        newCart.setValue(totalTVA, forKey: "total_tva")
        return newCart
    }
    
    func parseProduct(product: AnyObject, newCart: NSManagedObject, context: NSManagedObjectContext) -> NSManagedObject{
        var newProduct = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as NSManagedObject
        
        newProduct.setValue(product["product_id"] as Int, forKey: "id")
        newProduct.setValue(product["name"], forKey: "name")
        newProduct.setValue(product["short_name"], forKey: "short_name")
        
        if  product["extra"] is NSString {
            newProduct.setValue(product["extra"], forKey: "extra")
        }
        newProduct.setValue(product["vat"] as Float, forKey: "tva")
        newProduct.setValue(product["price"] as Float, forKey: "price")
        newProduct.setValue(1, forKey: "number");
        newProduct.setValue(newCart, forKey: "cart");
        return newProduct
    }
    
    func addProduct(products: NSMutableSet, newProduct: NSManagedObject) -> NSMutableSet {
        var found = false
        for p in products {
            if (p.valueForKey("id") as Int) == (newProduct.valueForKey("id") as Int) && (p.valueForKey("extra") as String? == newProduct.valueForKey("extra") as String?) {
                var n = 1
                if var nn = p.valueForKey("number") as? Int { n = nn }
                p.setValue(n + 1, forKey: "number")
                found = true
                break
            }
        }
        if !found {
            products.addObject(newProduct)
        }
        return products
    }
    
    
    // MARK: - Detailed view
    func clearDetailInfo(){
        detailView.backgroundColor = view.backgroundColor
        for (var subview) in detailView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func setDetailInfo(o: NSObject) {
        if (detailView.status == "confirm") {
            if (detailView.id != o.valueForKey("id").description){
                    detailView.status = "default"
            }
        }
        detailView.source = o
        detailView.id = o.valueForKey("id").description
        detailView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        detailView.setDetailInfo()
    }
    
    
    // MARK: - Filterbuttons
    func untoggleAll() {
        for b : FilterButton in filterBar.subviews as [FilterButton] {
            b.untoggle()
        }
    }
    
    func applyFilter() {
        switch (filter) {
        case "New":
            filterNew()
            break
        case "InProgress":
            filterInProgress()
            break
        case "NoPay":
            filterNoPay()
            break
        case "Done":
            filterDone()
            break
        case "History":
            filterHistory()
            break
        default:
            filterAll()
            break
        }
    }
    
    func filterAll() {
        filter = "All"
        selectedItems = items
        filterContentForSearchText(searchtext)
        tableView.reloadData()
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: chosen, inSection: 0))?.setHighlighted(true, animated: false)
    }
    func filterNew() {
        filter = "New"
        selectedItems = items.filter({( cart: NSObject) -> Bool in
            return cart.valueForKey("status") as NSString == "INIT"
        })
        filterContentForSearchText(searchtext)
        tableView.reloadData()
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: chosen, inSection: 0))?.setHighlighted(true, animated: false)
    }
    func filterInProgress() {
        filter = "InProgress"
        selectedItems = items.filter({( cart: NSObject) -> Bool in
            return cart.valueForKey("status") as NSString == "IN_PROGRESS"
        })
        filterContentForSearchText(searchtext)
        tableView.reloadData()
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: chosen, inSection: 0))?.setHighlighted(true, animated: false)
    }
    func filterDone() {
        filter = "Done"
        selectedItems = items.filter({( cart: NSObject) -> Bool in
            return cart.valueForKey("status") as NSString == "DONE"
        })
        filterContentForSearchText(searchtext)
        tableView.reloadData()
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: chosen, inSection: 0))?.setHighlighted(true, animated: false)
    }
    func filterNoPay() {
        filter = "NoPay"
        selectedItems = items.filter({( cart: NSObject) -> Bool in
            return cart.valueForKey("total_unpayed") as Float > 0
        })
        filterContentForSearchText(searchtext)
        tableView.reloadData()
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: chosen, inSection: 0))?.setHighlighted(true, animated: false)
    }
    func filterHistory() {
        filter = "History"
        selectedItems = items
        filterContentForSearchText(searchtext)
        tableView.reloadData()
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: chosen, inSection: 0))?.setHighlighted(true, animated: false)
    }
}