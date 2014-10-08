//
//  OrderTableViewCell.swift
//  ioPOS
//
//  Created by Louis on 03/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell, RestClientProtocol {

    let txtColor = UIColor(white: 1, alpha: 0.8)
    let darkGray = UIColor(red: 0.3, green: 0.32, blue: 0.32, alpha: 1)
    let lightGray = UIColor(white: 0.5, alpha: 1)
    let darkDarkGray = UIColor(white: 0.15, alpha: 1)
    
    var source: NSObject?
    var restaurant: String = "none"
    var status: String = "default"
    var parent: TitleViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            backgroundColor = lightGray
        } else {
            backgroundColor = darkGray
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCellStyle.Value1, reuseIdentifier: reuseIdentifier)
        initialize()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize(){
        backgroundColor = darkGray
        selectionStyle = UITableViewCellSelectionStyle.None
        frame.size.height = 140
        frame.size.width = 442
    }
    
    //----------WEBSERVICE
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
    }
    //--------------------
    
    func newLabel(frame: CGRect, text: String, align: NSTextAlignment) -> UILabel {
        var lbl = UILabel(frame: frame)
        lbl.text = text
        lbl.textColor = txtColor
        lbl.textAlignment = align
        return lbl
    }
    
    func addUnpayed(){
        var payeStmp = UILabel(frame: CGRectMake(204, 99, frame.size.width - 304, 20))
        payeStmp.backgroundColor = UIColor(red: 0.8, green: 0.5, blue: 0, alpha: 1)
        contentView.addSubview(payeStmp)
        
        var payeLbl = newLabel(CGRectMake(229, 99, frame.size.width - 304-25, 20),
            text: "NON PAYEE", align: NSTextAlignment.Center)
        payeLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        contentView.addSubview(payeLbl)
        
        var img = UIImageView(frame: CGRectMake(205, 100, 23, 18))
        img.image = UIImage(named: "Icone_No-pay.png")
        contentView.addSubview(img)
    }
    
    func addSeparator(frame: CGRect){
        var separator = UILabel(frame: frame)
        separator.backgroundColor = darkDarkGray
        contentView.addSubview(separator)
    }
    
    func setInfo(o: NSObject) {
        source = o
        
        addSeparator(CGRectMake(0, 0, frame.size.width, 15))
        addSeparator(CGRectMake(0, frame.size.height-45, frame.size.width, 45))
        addSeparator(CGRectMake(0, 0, 100, frame.size.height))
        addSeparator(CGRectMake(frame.size.width - 100, 0, 100, frame.size.height))
        
        var name: String = ""
        if (o.valueForKey("client") != nil) {
            if o.valueForKey("client").valueForKey("firstname") != nil {
                name += o.valueForKey("client").valueForKey("firstname").description + " "
            }
            if o.valueForKey("client").valueForKey("lastname") != nil {
                name += o.valueForKey("client").valueForKey("lastname").description
            }
        }
        var nameLbl = newLabel(CGRectMake(104, 19, 300, 16),
            text: name, align: NSTextAlignment.Left)
        nameLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        nameLbl.sizeToFit()
        contentView.addSubview(nameLbl)
        
        var id: String = "n°"
        id += o.valueForKey("id").description
        var idLbl = newLabel(CGRectMake(108 + nameLbl.frame.width, 23, 100, 12),
            text: id, align: NSTextAlignment.Left)
        idLbl.font = UIFont(name: "HelveticaNeue", size: 12)
        contentView.addSubview(idLbl)
        
        var typeLbl = newLabel(CGRectMake(104, 23 + nameLbl.frame.height, 50, 20),
            text: "Commande ONLINE", align: NSTextAlignment.Left)
        typeLbl.font = UIFont(name: "HelveticaNeue", size: 12)
        typeLbl.sizeToFit()
        contentView.addSubview(typeLbl)
        
        //TMP
        /*var statusLbl = UILabel(frame: CGRectMake(104, 32 + nameLbl.frame.height, 50, 20))
        statusLbl.text = o.valueForKey("status").description;
        statusLbl.textColor = txtColor
        statusLbl.textAlignment = NSTextAlignment.Left
        statusLbl.font = UIFont(name: "HelveticaNeue", size: 12)
        statusLbl.sizeToFit()
        contentView.addSubview(statusLbl)*/
        //
        
        //--------------TIME
        var timeStmp = UILabel(frame: CGRectMake(100, 99, 100, 20))
        timeStmp.backgroundColor = UIColor(white: 0.25, alpha: 1)
        contentView.addSubview(timeStmp)
        
        var nstime : NSString = o.valueForKey("delivery").description
        var time: String = (nstime.substringFromIndex(11) as NSString).substringToIndex(5)
        var timeLbl = newLabel(CGRectMake(100, 99, 100, 20), text: time, align: NSTextAlignment.Center)
        timeLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        contentView.addSubview(timeLbl)
        //------------------
        
        var price: String = NSString(format: "%.02f", locale: nil, o.valueForKey("total") as Float) + "€"
        var priceLbl = newLabel(CGRectMake(frame.width - 254, 95-44, 150, 40),
            text: price, align: NSTextAlignment.Right)
        priceLbl.font = UIFont(name: "HelveticaNeue-Thin", size: 40)
        contentView.addSubview(priceLbl)
        
        //----STATUS-BUTTONS
        let status = o.valueForKey("status").description
        if status == "INIT" {
            var validateB = UIButton(frame: CGRectMake(frame.size.width - 96, 15, 84, 80))
            validateB.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0.2, alpha: 1)
            validateB.setTitle("V", forState: UIControlState.Normal)
            validateB.setTitleColor(txtColor, forState: UIControlState.Normal)
            validateB.addTarget(self, action: "validate", forControlEvents: UIControlEvents.TouchDown)
            contentView.addSubview(validateB)
            
            var discardB = UIButton(frame: CGRectMake(frame.size.width - 96, 99, 84, 20))
            discardB.backgroundColor = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
            discardB.setTitle("x", forState: UIControlState.Normal)
            discardB.setTitleColor(txtColor, forState: UIControlState.Normal)
            discardB.addTarget(self, action: "discard", forControlEvents: UIControlEvents.TouchDown)
            contentView.addSubview(discardB)
        }
        //------------------
        
        if o.valueForKey("total_unpayed") as Float > 0 {
            addUnpayed()
        }
        
        //-------------IMAGE
        var circle = UIImageView(frame: CGRectMake(0, 15, 81, 81))
        var small = UIImageView(frame: CGRectMake(65, 0, 30, 30))
        var center = UIImageView(frame: CGRectMake(27, 15 + 17, 27, 45))
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
        contentView.addSubview(circle)
        contentView.addSubview(small)
        contentView.addSubview(center)
        //------------------
    }
}
