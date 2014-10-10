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
    var darkDarkGray = UIColor(white: 0.15, alpha: 1)
    
    var source: NSObject?
    var restaurant: String = "none"
    var status: String = "default"
    var parent: TitleViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            backgroundColor = lightGray
        } else {
            backgroundColor = darkGray
        }
    }

    // MARK: - Initialization
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
        frame.size.width = 520
    }
    
    
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
    }
    
    
    // MARK: - Tools
    func newLabel(frame: CGRect, text: String, align: NSTextAlignment) -> UILabel {
        var lbl = UILabel(frame: frame)
        lbl.text = text
        lbl.textColor = txtColor
        lbl.textAlignment = align
        return lbl
    }
    
    func addSeparator(frame: CGRect){
        var separator = UILabel(frame: frame)
        separator.backgroundColor = darkDarkGray
        contentView.addSubview(separator)
    }
    
    func newButton(frame: CGRect, color: UIColor, title: String) -> UIButton {
        var button = UIButton(frame: frame)
        button.backgroundColor = color
        var ico = UIImageView(frame: CGRectMake(frame.width/2 - 6, frame.height/2 - 6, 12, 12))
        ico.image = UIImage(named: title)
        button.addSubview(ico)
        return button
    }
    
    
    // MARK: - Content functions
    func setCircle(){
        let status = source!.valueForKey("status").description
        
        var circle = UIImageView(frame: CGRectMake(0, 15, 81, 81))
        if status == "INIT" {
            circle.image = UIImage(named: "Icone_Ellipse.png")
        } else if status == "IN_PROGRESS" {
            circle.image = UIImage(named: "Icone_Ellipse-Blue.png")
        } else {
            circle.image = UIImage(named: "Icone_Ellipse.png")
        }
        contentView.addSubview(circle)
    }
    func setLogo(){
        let status = source!.valueForKey("status").description
        
        var logo = UIImageView(frame: CGRectMake(65, 0, 30, 30))
        if status == "INIT" {
            logo.image = UIImage(named: "Icone_Add-Red.png")
        } else if status == "IN_PROGRESS" {
            logo.image = UIImage(named: "Icone_InProgress-Blue.png")
        } else {
            logo.image = UIImage(named: "Icone_Done.png")
        }
        contentView.addSubview(logo)
    }
    func setCenterLogo(){
        var center = UIImageView(frame: CGRectMake(27, 15 + 17, 27, 45))
        center.image = UIImage(named: "Icone_Bag.png")
        contentView.addSubview(center)
    }
    
    func setUnpayed(){
        if source!.valueForKey("total_unpayed") as Float > 0 {
            let width: CGFloat = (frame.size.width - 184) / 2
            var payeStmp = UILabel(frame: CGRectMake(width + 104, 99, width, 30))
            payeStmp.backgroundColor = UIColor(red: 0.8, green: 0.5, blue: 0, alpha: 1)
            contentView.addSubview(payeStmp)
            
            var payeLbl = newLabel(CGRectMake(width + 134, 99, width - 30, 30),
                text: "NON PAYEE", align: NSTextAlignment.Center)
            payeLbl.font = UIFont(name: "HelveticaNeue", size: 16)
            contentView.addSubview(payeLbl)
            
            var img = UIImageView(frame: CGRectMake(width + 110, 105, 23, 18))
            img.image = UIImage(named: "Icone_No-pay.png")
            contentView.addSubview(img)
        }
    }
    
    func setClientLabel()-> CGSize{
        var name: String = ""
        if (source!.valueForKey("client") != nil) {
            if source!.valueForKey("client").valueForKey("firstname") != nil {
                name += source!.valueForKey("client").valueForKey("firstname").description + " "
            }
            if source!.valueForKey("client").valueForKey("lastname") != nil {
                name += source!.valueForKey("client").valueForKey("lastname").description
            }
        }
        var nameLbl = newLabel(CGRectMake(110, 19, 300, 16),
            text: name, align: NSTextAlignment.Left)
        nameLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        nameLbl.sizeToFit()
        contentView.addSubview(nameLbl)
        return nameLbl.frame.size
    }
    
    func setIdLabel(nameSize: CGSize) {
        var id: String = "n°"
        if (source!.valueForKey("id") != nil){
            id += source!.valueForKey("id").description
        } else {
            id += "???"
        }
        var idLbl = newLabel(CGRectMake(120 + nameSize.width, 23, 100, 12),
            text: id, align: NSTextAlignment.Left)
        idLbl.font = UIFont(name: "HelveticaNeue", size: 12)
        contentView.addSubview(idLbl)
    }
    
    func setTypeLabel(nameSize: CGSize) {
        var typeLbl = newLabel(CGRectMake(110, 23 + nameSize.height, 50, 20),
            text: "Commande ONLINE", align: NSTextAlignment.Left)
        typeLbl.font = UIFont(name: "HelveticaNeue", size: 12)
        typeLbl.sizeToFit()
        contentView.addSubview(typeLbl)
    }
    
    func setPriceLabel() {
        var price: String = source!.valueForKey("total") != nil ? NSString(format: "%.02f", locale: nil, source!.valueForKey("total") as Float) + "€" : "??.??€"
        var priceLbl = newLabel(CGRectMake(frame.width - 290, 91 - 50, 200, 50),
            text: price, align: NSTextAlignment.Right)
        priceLbl.font = UIFont(name: "HelveticaNeue-Thin", size: 50)
        contentView.addSubview(priceLbl)
    }
    
    func setTimeLabel() {
        let width: CGFloat = (frame.size.width - 184) / 2
        var timeStmp = UILabel(frame: CGRectMake(100, 99, width, 30))
        timeStmp.backgroundColor = UIColor(white: 0.25, alpha: 1)
        contentView.addSubview(timeStmp)
        
        var nstime : NSString = (source!.valueForKey("delivery") != nil) ? source!.valueForKey("delivery").description : "..........??:??"
        var time: String = (nstime.substringFromIndex(11) as NSString).substringToIndex(5)
        var timeLbl = newLabel(CGRectMake(100, 99, width, 30), text: time, align: NSTextAlignment.Center)
        timeLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        contentView.addSubview(timeLbl)
    }
    
    func setButtons() {
        let status = source!.valueForKey("status").description
        if status == "INIT" {
            var validateB = newButton(CGRectMake(frame.size.width - 76, 15, 64, 80),
                color: UIColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 1), title: "Icone_Done.png")
            validateB.addTarget(self, action: "validate", forControlEvents: UIControlEvents.TouchDown)
            contentView.addSubview(validateB)
            
            var discardB = newButton(CGRectMake(frame.size.width - 76, 99,64, 30),
                color: UIColor(red: 0.8, green: 0, blue: 0, alpha: 1), title: "Icone_Discard.png")
            discardB.addTarget(self, action: "discard", forControlEvents: UIControlEvents.TouchDown)
            contentView.addSubview(discardB)
        }
    }
    
    func setInfo(o: NSObject) {
        source = o
        
        addSeparator(CGRectMake(0, 0, frame.size.width, 15))
        addSeparator(CGRectMake(0, frame.size.height - 45, frame.size.width, 45))
        addSeparator(CGRectMake(0, 0, 100, frame.size.height))
        addSeparator(CGRectMake(frame.size.width - 80, 0, 100, frame.size.height))
        
        let nameSize = setClientLabel()
        setIdLabel(nameSize)
        setTypeLabel(nameSize)
        setPriceLabel()
        
        setTimeLabel()
        setButtons()
        setUnpayed()
        
        setCircle()
        setLogo()
        setCenterLogo()
    }
}
