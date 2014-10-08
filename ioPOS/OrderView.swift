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
    
    var source: NSObject?
    var restaurant: String = "none"
    var status: String = "default"
    var parent: TitleViewController?
    
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
        if (source != nil) && status == "default" {
            status = "cancel"
            println("cancel")
            let restClient = RestClient()
            restClient.delegate = self;
            restClient.cancel(restaurant, cartId: source!.valueForKey("id").description);
        }
    }
    
    func didRecieveResponse(results: NSDictionary) {
        parent!.loadOrders()
        status = "default"
    }
    
    func didFailWithError(error: NSError!) {
        status = "default"
        println("Failed to update cart")
    }
    
    func newLabel(frame: CGRect, text: String, align: NSTextAlignment) -> UILabel {
        var lbl = UILabel(frame: frame)
        lbl.text = text
        lbl.textAlignment = align
        return lbl
    }
    
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
    
    func setProducts(){
        let wdth = frame.size.width
        
        var productList = UIScrollView(frame: CGRectMake(10, y, wdth - 20, 381))
        var subY: CGFloat = 0
        var products: NSMutableSet = source!.valueForKey("products") as NSMutableSet
        for p in products {
            var pr: NSObject = p as NSObject
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
            
            subY += 5
        }
        var size: CGSize = productList.frame.size
        size.height = subY
        productList.contentSize = size
        addSubview(productList)
        y += productList.frame.size.height
    }
    
    func addSeparator(){
        y += 5
        var sep = UILabel(frame: CGRectMake(10, y, frame.size.width - 20, 1))
        sep.backgroundColor = gray
        addSubview(sep)
        y += 6
    }
    
    func setTotal(){
        let wdth = frame.size.width
        let price: Float = source!.valueForKey("total") as Float
        let tva: Float = source!.valueForKey("total_tva") as Float
        let ht: Float = price - tva
        
        var totalTTC = newLabel(CGRectMake(10, y + 13, wdth - 150 - 20, 16),
            text: "Total", align: NSTextAlignment.Right)
        totalTTC.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        addSubview(totalTTC)
        
        var priceLbl = newLabel(CGRectMake(wdth - 150 - 10, y, 150, 30),
            text: NSString(format: "%.02f", locale: nil, price) + "€", align: NSTextAlignment.Right)
        priceLbl.font = UIFont(name: "HelveticaNeue", size: 30)
        addSubview(priceLbl)
        y += priceLbl.frame.size.height + 4
        
        var totalTVA = newLabel(CGRectMake(10, y, wdth - 80 - 20, 12),
            text: "TVA", align: NSTextAlignment.Right)
        totalTVA.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        addSubview(totalTVA)
        
        var tvaLbl = newLabel(CGRectMake(wdth - 80 - 20, y, 80, 12),
            text: NSString(format: "%.02f", locale: nil, tva) + "€", align: NSTextAlignment.Right)
        tvaLbl.font = UIFont(name: "HelveticaNeue", size: 12)
        addSubview(tvaLbl)
        y += tvaLbl.frame.size.height + 4
        
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
        var discardB = UIButton(frame: CGRectMake(10, y, 80, 50))
        discardB.backgroundColor = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
        discardB.setTitle("x", forState: UIControlState.Normal)
        discardB.setTitleColor(txtWhite, forState: UIControlState.Normal)
        discardB.addTarget(self, action: "discard", forControlEvents: UIControlEvents.TouchDown)
        addSubview(discardB)
        
        var validateB = UIButton(frame: CGRectMake(80 + 20, y, frame.size.width - 80 - 30, 50))
        validateB.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0.2, alpha: 1)
        validateB.setTitle("V", forState: UIControlState.Normal)
        validateB.setTitleColor(txtWhite, forState: UIControlState.Normal)
        validateB.addTarget(self, action: "validate", forControlEvents: UIControlEvents.TouchDown)
        addSubview(validateB)
        y += 10 + validateB.frame.size.height
    }
    
    func setImage(){
        let status = source!.valueForKey("status").description
        
        var circle = UIImageView(frame: CGRectMake(10, 20, 81, 81))
        var small = UIImageView(frame: CGRectMake(10 + 65, 5, 30, 30))
        var center = UIImageView(frame: CGRectMake(10 + 27, 20 + 17, 27, 45))
        center.image = UIImage(named: "Icone_Bag.png")
        if status == "INIT" {
            circle.image = UIImage(named: "Icone_Ellipse.png")
            small.image = UIImage(named: "Icone_Add.png")
        } else if status == "IN_PROGRESS" {
            circle.image = UIImage(named: "Icone_Ellipse-Blue.png")
            small.image = UIImage(named: "Icone_InProgress.png")
        } else {
            circle.image = UIImage(named: "Icone_Ellipse.png")
            small.image = UIImage(named: "Icone_Done.png")
        }
        addSubview(circle)
        addSubview(small)
        addSubview(center)
    }
    
    func setUnpayed(){
        y += 5
        if source!.valueForKey("total_unpayed") as Float > 0 {
            var payeStmp = UILabel(frame: CGRectMake(10, y, frame.size.width - 364, 20))
            payeStmp.backgroundColor = UIColor(red: 0.8, green: 0.5, blue: 0, alpha: 1)
            addSubview(payeStmp)
            
            var payeLbl = newLabel(CGRectMake(35, y, frame.size.width - 364-25, 20),
                text: "NON PAYEE", align: NSTextAlignment.Center)
            payeLbl.textColor = backgroundColor!
            payeLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
            addSubview(payeLbl)
            
            var img = UIImageView(frame: CGRectMake(11, y + 1, 23, 18))
            img.image = UIImage(named: "Icone_No-pay.png")
            addSubview(img)
        }
        y += 25
    }
    
    func setDetailInfo() {
        y = 5
        let wdth = frame.size.width
        
        setUserName()
        setDetails()
        setUnpayed()
        addSeparator()
        setProducts()
        addSeparator()
        setTotal()
        setButtons()
        setImage()
    }
}
