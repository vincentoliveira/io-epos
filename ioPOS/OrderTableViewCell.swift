//
//  OrderTableViewCell.swift
//  ioPOS
//
//  Created by Louis on 03/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell, RestClientProtocol {

    // MARK: - Attributes
    let txtColor = UIColor(white: 1, alpha: 0.8)
    let darkGray = UIColor(red: 0.3, green: 0.32, blue: 0.32, alpha: 1)
    let lightGray = UIColor(white: 0.5, alpha: 1)
    var darkDarkGray = UIColor(white: 0.15, alpha: 1)
    
    var source: NSObject?
    var restaurant: String = "none"
    var status: String = "default"
    var parent: TitleViewController?
    var main: UIView?
    
    // MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(highlight: Bool, animated: Bool) {
        if highlight {
            main?.backgroundColor = lightGray
            main?.layer.shadowOpacity = 0.3
        } else {
            main?.backgroundColor = darkGray
            main?.layer.shadowOpacity = 0
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
        selectionStyle = UITableViewCellSelectionStyle.None
        frame.size.height = 140
        frame.size.width = 480
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
    func addHighlight() {
        main = UIView(frame: CGRectMake(60, 15, frame.size.width - 140, frame.size.height - 60))
        main?.backgroundColor = darkGray
        main?.layer.shadowOpacity = 0
        main?.layer.shadowColor = UIColor.whiteColor().CGColor
        main?.layer.shadowRadius = 5
        main?.layer.shadowOffset = CGSize(width: 0, height: 0)
        addSubview(main!)
    }
    
    func setCircle(){
        let status = source!.valueForKey("status") != nil ? source!.valueForKey("status").description : "DONE"
        
        var circle = UIImageView(frame: CGRectMake(0, 15, 50, 50))
        if status == "INIT" {
            circle.image = UIImage(named: "Icone_Ellipse-Green.png")
        } else if status == "IN_PROGRESS" {
            circle.image = UIImage(named: "Icone_Ellipse-Blue.png")
        } else {
            circle.image = UIImage(named: "Icone_Ellipse.png")
        }
        contentView.addSubview(circle)
    }
    func setLogo(){
        let status = source!.valueForKey("status") != nil ? source!.valueForKey("status").description : "DONE"
        
        var logo = UIImageView(frame: CGRectMake(40, 2, 16, 16))
        if status == "INIT" {
            logo.image = UIImage(named: "Icone_Add-Green.png")
        } else if status == "IN_PROGRESS" {
            logo.image = UIImage(named: "Icone_InProgress-Blue.png")
        } else {
            logo.image = UIImage(named: "Icone_Done.png")
        }
        contentView.addSubview(logo)
    }
    func setCenterLogo(){
        var center = UIImageView(frame: CGRectMake(16, 15 + 10, 18, 30))
        center.image = UIImage(named: "Icone_Bag.png")
        contentView.addSubview(center)
    }
    
    func setUnpayed(){
        if source!.valueForKey("total_unpayed") != nil {
            var unpayed = source!.valueForKey("total_unpayed") as Float > 0
            let width: CGFloat = (frame.size.width - 144) / 2
            
            var payeStmp = UILabel(frame: CGRectMake(width + 64, 99, width, 30))
            payeStmp.backgroundColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
            if unpayed { contentView.addSubview(payeStmp) }
            
            var wdth: CGFloat = unpayed ? 23 : 18
            var img = UIImageView(frame: CGRectMake(width + 70, 105, wdth, 18))
            img.image = UIImage(named: unpayed ? "Icone_NoPay.png" : "Icone_Done-Green.png")
            contentView.addSubview(img)
            
            var payeLbl = newLabel(CGRectMake(width + 71 + wdth, 99, width - 7 - wdth, 30),
                text: unpayed ? "NON PAYEE" : "PAYEE", align: NSTextAlignment.Center)
            if !unpayed { payeLbl.textColor = UIColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1) }
            payeLbl.font = UIFont(name: "HelveticaNeue", size: 16)
            contentView.addSubview(payeLbl)
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
        } else {name = "???"}
        var nameLbl = newLabel(CGRectMake(10, 4, 300, 16),
            text: name, align: NSTextAlignment.Left)
        nameLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        nameLbl.sizeToFit()
        main?.addSubview(nameLbl)
        return nameLbl.frame.size
    }
    
    func setIdLabel(nameSize: CGSize) {
        var id: String = "n°"
        if (source!.valueForKey("id") != nil){
            id += source!.valueForKey("id").description
        } else {
            id += "???"
        }
        var idLbl = newLabel(CGRectMake(20 + nameSize.width, 4, 100, 16),
            text: id, align: NSTextAlignment.Left)
        idLbl.font = UIFont(name: "HelveticaNeue", size: 16)
        idLbl.sizeToFit()
        main?.addSubview(idLbl)
    }
    
    func setTypeLabel(nameSize: CGSize) {
        var type = (source != nil && source!.valueForKey("source") != nil) ? source!.valueForKey("source").description : "UNKNOWN"
        var typeLbl = newLabel(CGRectMake(10, 8 + nameSize.height, 50, 20),
            text: "Commande " + type, align: NSTextAlignment.Left)
        typeLbl.font = UIFont(name: "HelveticaNeue", size: 12)
        typeLbl.sizeToFit()
        main?.addSubview(typeLbl)
    }
    
    func setPriceLabel() {
        var price: String = source!.valueForKey("total") != nil ? NSString(format: "%.02f", locale: nil, source!.valueForKey("total") as Float) + "€" : "??.??€"
        var priceLbl = newLabel(CGRectMake(main!.frame.width - 210, 31, 200, 50),
            text: price, align: NSTextAlignment.Right)
        priceLbl.font = UIFont(name: "HelveticaNeue-Thin", size: 50)
        main?.addSubview(priceLbl)
    }
    
    func setTimeLabel() {
        let width: CGFloat = (frame.size.width - 144) / 2
        var timeStmp = UILabel(frame: CGRectMake(60, 99, width, 30))
        timeStmp.backgroundColor = UIColor(red: 0.26, green: 0.25, blue: 0.25, alpha: 1)
        contentView.addSubview(timeStmp)
        
        var nstime : NSString = (source!.valueForKey("delivery") != nil) ? source!.valueForKey("delivery").description : "...........??:??.."
        var time: String = (nstime.substringFromIndex(11) as NSString).substringToIndex(5)
        var timeLbl = newLabel(CGRectMake(60, 99, width, 30), text: time, align: NSTextAlignment.Center)
        timeLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        contentView.addSubview(timeLbl)
    }
    
    // TODO: Define UI
    func setButtons() {
        let status = (source != nil && source!.valueForKey("status") != nil) ? source!.valueForKey("status").description : "DONE"
        if status == "INIT" {
            var validateB = newButton(CGRectMake(frame.size.width - 76, 15, 64, 80),
                color: UIColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1), title: "Icone_Done.png")
            validateB.addTarget(self, action: "validate", forControlEvents: UIControlEvents.TouchDown)
            contentView.addSubview(validateB)
            
            /*var discardB = newButton(CGRectMake(frame.size.width - 76, 99,64, 30),
                color: UIColor(red: 0.8, green: 0, blue: 0, alpha: 1), title: "Icone_Discard.png")
            discardB.addTarget(self, action: "discard", forControlEvents: UIControlEvents.TouchDown)
            contentView.addSubview(discardB)*/
        }
    }
    
    func setInfo(o: NSObject) {
        source = o
        
        backgroundColor = darkDarkGray
        addHighlight()
        
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
