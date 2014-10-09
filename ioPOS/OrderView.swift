//
//  OrderView.swift
//  ioPOS
//
//  Created by Louis on 06/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit

class OrderView: UIView, RestClientProtocol {
    
    let bgc = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
    let gray = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    
    var y: CGFloat = 5
    var subY: CGFloat = 0
    
    var source: NSObject?
    var restaurant: String = "none"
    var status: String = "default"
    var parent: TitleViewController?
    
    
    // MARK: - Buttons functions
    func validate(){
        if (source != nil) && status == "default" {
            status = "next"
            println("next status")
            let restClient = RestClient()
            restClient.delegate = self;
            restClient.nextStatus(restaurant, cartId: source!.valueForKey("id").description);
        }
    }
    
    func discard(){
        //parent!.performSegueWithIdentifier("discard", sender: parent)
        if (source != nil) && status == "default" {
            status = "cancel"
            println("cancel")
            let restClient = RestClient()
            restClient.delegate = self;
            restClient.cancel(restaurant, cartId: source!.valueForKey("id").description);
        }
    }
    
    
    // MARK: - Webservice functions
    func didRecieveResponse(results: NSDictionary) {
        parent!.loadOrders()
        status = "default"
    }
    
    func didFailWithError(error: NSError!) {
        status = "default"
        println("Failed to update cart")
    }
    
    
    // MARK: - Tools
    func newLabel(frame: CGRect, text: String, align: NSTextAlignment) -> UILabel {
        var lbl = UILabel(frame: frame)
        lbl.text = text
        lbl.textAlignment = align
        return lbl
    }
    
    func newButton(frame: CGRect, color: UIColor, title: String) -> UIButton {
        var button = UIButton(frame: frame)
        button.backgroundColor = color
        // TMP {
        button.setTitle(title, forState: UIControlState.Normal)
        button.setTitleColor(UIColor(white: 1, alpha: 1), forState: UIControlState.Normal)
        // }
        return button
    }
    
    func addSeparator(){
        y += 5
        var sep = UILabel(frame: CGRectMake(10, y, frame.size.width - 20, 1))
        sep.backgroundColor = gray
        addSubview(sep)
        y += 6
    }
    
    
    // MARK: - Content functions
    func setUserName(){
        var name: String = ""
        if (source!.valueForKey("client") != nil) {
            if source!.valueForKey("client").valueForKey("firstname") != nil {
                name += source!.valueForKey("client").valueForKey("firstname").description + " "
            }
            if source!.valueForKey("client").valueForKey("lastname") != nil {
                name += source!.valueForKey("client").valueForKey("lastname").description
            }
        }
        var nameLbl = newLabel(CGRectMake(115, y, 300, 42), text: name, align: NSTextAlignment.Left)
        nameLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
        addSubview(nameLbl)
        y += nameLbl.frame.height
    }
    
    func setDetails(){
        var id: String = "N°"
        id += source!.valueForKey("id").description + "\n"
        id += "Commande ONLINE\n"
        var nstime : NSString = source!.valueForKey("delivery").description
        id += (nstime.substringFromIndex(11) as NSString).substringToIndex(5)
        
        var idLbl = newLabel(CGRectMake(115, y, 300, 63), text: id, align: NSTextAlignment.Left)
        idLbl.textColor = gray
        idLbl.numberOfLines = 3
        addSubview(idLbl)
        y += idLbl.frame.height
    }
    
    func setCircle(){
        let status = source!.valueForKey("status").description
        
        var circle = UIImageView(frame: CGRectMake(10, 20, 81, 81))
        if status == "INIT" {
            circle.image = UIImage(named: "Icone_Ellipse.png")
        } else if status == "IN_PROGRESS" {
            circle.image = UIImage(named: "Icone_Ellipse-Blue.png")
        } else {
            circle.image = UIImage(named: "Icone_Ellipse.png")
        }
        addSubview(circle)
    }
    func setLogo(){
        let status = source!.valueForKey("status").description
        
        var logo = UIImageView(frame: CGRectMake(10 + 65, 5, 30, 30))
        if status == "INIT" {
            logo.image = UIImage(named: "Icone_Add.png")
        } else if status == "IN_PROGRESS" {
            logo.image = UIImage(named: "Icone_InProgress.png")
        } else {
            logo.image = UIImage(named: "Icone_Done.png")
        }
        addSubview(logo)
    }
    func setCenterLogo(){
        var center = UIImageView(frame: CGRectMake(10 + 27, 20 + 17, 27, 45))
        center.image = UIImage(named: "Icone_Bag-Black.png")
        addSubview(center)
    }
    
    func setUnpayed(){
        y += 5
        if source!.valueForKey("total_unpayed") as Float > 0 {
            var payeStmp = UILabel(frame: CGRectMake(10, y, frame.size.width / 2, 30))
            payeStmp.backgroundColor = UIColor(red: 0.8, green: 0.5, blue: 0, alpha: 1)
            addSubview(payeStmp)
            
            var payeLbl = newLabel(CGRectMake(35, y, frame.size.width / 2 - 35, 30),
                text: "NON PAYEE", align: NSTextAlignment.Center)
            payeLbl.textColor = backgroundColor!
            payeLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
            addSubview(payeLbl)
            
            var img = UIImageView(frame: CGRectMake(21, y + 6, 23, 18))
            img.image = UIImage(named: "Icone_No-pay.png")
            addSubview(img)
        }
        y += 35
    }
    
    func setProducts(){
        subY = 0

        var productList = UIScrollView(frame: CGRectMake(10, y, frame.size.width - 20, 371))
        var nameDescriptor = NSSortDescriptor(key: "name", ascending: true)
        var notOrderedProducts: NSMutableSet = source!.valueForKey("products") as NSMutableSet
        var products = notOrderedProducts.sortedArrayUsingDescriptors([nameDescriptor])
        for p in products {
            addProduct(p as NSObject, productList: productList)
            subY += 5
        }
        var size: CGSize = productList.frame.size
        size.height = subY
        productList.contentSize = size
        addSubview(productList)
        y += productList.frame.size.height
    }
    
    func addProduct(pr: NSObject, productList: UIScrollView){
        let wdth = frame.size.width
        var nb = pr.valueForKey("number") as Float
        var price = pr.valueForKey("price") as Float
        
        var subNameLbl = newLabel(CGRectMake(10, subY, wdth - 40 - 80, 21),
            text: Int(nb).description + " " + pr.valueForKey("name").description,
            align: NSTextAlignment.Left)
        productList.addSubview(subNameLbl)
        
        var subPriceLbl = newLabel(CGRectMake(wdth - 80 - 30, subY, 80, 21),
            text: NSString(format: "%.02f", locale: nil, (price * nb)) + "€",
            align: NSTextAlignment.Right)
        productList.addSubview(subPriceLbl)
        
        subY += subNameLbl.frame.height
        
        if pr.valueForKey("extra") != nil {
            var extraLbl = newLabel(CGRectMake(30, subY, wdth-60, 10),
                text: pr.valueForKey("extra").description,
                align: NSTextAlignment.Left)
            extraLbl.font = UIFont(name: "HelveticaNeue", size: 11)
            productList.addSubview(extraLbl)
            subY += extraLbl.frame.height
        }
    }
    
    func setPrice(){
        let price: Float = source!.valueForKey("total") as Float
        let tva: Float = source!.valueForKey("total_tva") as Float
        let ht: Float = price - tva
        setTotal(price)
        setTVA(tva)
        setHT(ht)
    }
    func setTotal(price: Float){
        let wdth = frame.size.width
        var totalTTC = newLabel(CGRectMake(10, y + 13, wdth - 150 - 20, 16),
            text: "Total", align: NSTextAlignment.Right)
        totalTTC.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        addSubview(totalTTC)
        
        var priceLbl = newLabel(CGRectMake(wdth - 150 - 10, y, 150, 30),
            text: NSString(format: "%.02f", locale: nil, price) + "€", align: NSTextAlignment.Right)
        priceLbl.font = UIFont(name: "HelveticaNeue", size: 30)
        addSubview(priceLbl)
        y += priceLbl.frame.size.height + 4
        
    }
    func setTVA(tva: Float){
        let wdth = frame.size.width
        var totalTVA = newLabel(CGRectMake(10, y, wdth - 80 - 20, 12),
            text: "TVA", align: NSTextAlignment.Right)
        totalTVA.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        addSubview(totalTVA)
        
        var tvaLbl = newLabel(CGRectMake(wdth - 80 - 20, y, 80, 12),
            text: NSString(format: "%.02f", locale: nil, tva) + "€", align: NSTextAlignment.Right)
        tvaLbl.font = UIFont(name: "HelveticaNeue", size: 12)
        addSubview(tvaLbl)
        y += tvaLbl.frame.size.height + 4
    }
    func setHT(ht: Float){
        let wdth = frame.size.width
        var totalHT = newLabel(CGRectMake(10, y, wdth - 80 - 20, 12),
            text: "Total HT", align: NSTextAlignment.Right)
        totalHT.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        addSubview(totalHT)
        
        var htLbl = newLabel(CGRectMake(wdth - 80 - 20, y, 80, 12),
            text: NSString(format: "%.02f", locale: nil, ht) + "€", align: NSTextAlignment.Right)
        htLbl.font = UIFont(name: "HelveticaNeue", size: 12)
        addSubview(htLbl)
        y += htLbl.frame.size.height + 4
    }
    
    func setButtons(){
        let txtWhite = UIColor(white: 1, alpha: 0.8)
        y += 10
        var discardB = newButton(CGRectMake(10, y, 80, 50),
            color: UIColor(red: 0.8, green: 0, blue: 0, alpha: 1), title: "Annuler")
        discardB.addTarget(self, action: "discard", forControlEvents: UIControlEvents.TouchDown)
        addSubview(discardB)
        
        var validateB = newButton(CGRectMake(80 + 20, y, frame.size.width - 80 - 30, 50),
            color: UIColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 1), title: "Etape suivante")
        validateB.addTarget(self, action: "validate", forControlEvents: UIControlEvents.TouchDown)
        addSubview(validateB)
        y += 10 + validateB.frame.size.height
    }
    
    func setDetailInfo() {
        y = 5
        
        setCircle()
        setLogo()
        setCenterLogo()
        
        setUserName()
        setDetails()
        setUnpayed()
        addSeparator()
        setProducts()
        addSeparator()
        setPrice()
        setButtons()
    }
}
