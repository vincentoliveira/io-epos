//
//  OrderTableViewCell.swift
//  ioPOS
//
//  Created by Louis on 03/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    let txtColor = UIColor(white: 1, alpha: 0.8)
    let darkGray = UIColor(red: 0.3, green: 0.32, blue: 0.32, alpha: 1)
    let lightGray = UIColor(white: 0.5, alpha: 1)
    let darkDarkGray = UIColor(white: 0.15, alpha: 1)
    
    var source: NSObject?
    
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
        frame.size.height = 160
        frame.size.width = 477
    }
    
    func validate(){
        println("validate :")
        println(source?.description)
        //ADD WEBSERVICE
    }
    
    func discard(){
        println("discard :")
        println(source?.description)
        //ADD WEBSERVICE
    }
    
    func setInfo(o: NSObject) {
        source = o
        
        var name: String = ""
        if (o.valueForKey("client") != nil) {
            if o.valueForKey("client").valueForKey("firstname") != nil {
                name += o.valueForKey("client").valueForKey("firstname").description + " "
            }
            if o.valueForKey("client").valueForKey("lastname") != nil {
                name += o.valueForKey("client").valueForKey("lastname").description
            }
        }
        var nameLbl = UILabel(frame: CGRectMake(104, 4, 300, 16))
        nameLbl.text = name;
        nameLbl.textColor = txtColor
        nameLbl.textAlignment = NSTextAlignment.Left
        nameLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        nameLbl.sizeToFit()
        contentView.addSubview(nameLbl)
        
        var id: String = "n°"
        id += o.valueForKey("id").description
        var idLbl = UILabel(frame: CGRectMake(108 + nameLbl.frame.width, 8, 100, 12))
        idLbl.text = id;
        idLbl.textColor = txtColor
        idLbl.textAlignment = NSTextAlignment.Left
        idLbl.font = UIFont(name: "HelveticaNeue", size: 12)
        contentView.addSubview(idLbl)
        
        var typeLbl = UILabel(frame: CGRectMake(104, 8 + nameLbl.frame.height, 50, 20))
        typeLbl.text = "Commande ONLINE";
        typeLbl.textColor = txtColor
        typeLbl.textAlignment = NSTextAlignment.Left
        typeLbl.font = UIFont(name: "HelveticaNeue", size: 12)
        typeLbl.sizeToFit()
        contentView.addSubview(typeLbl)
        
        //TMP
        var statusLbl = UILabel(frame: CGRectMake(104, 32 + nameLbl.frame.height, 50, 20))
        statusLbl.text = o.valueForKey("status").description;
        statusLbl.textColor = txtColor
        statusLbl.textAlignment = NSTextAlignment.Left
        statusLbl.font = UIFont(name: "HelveticaNeue", size: 12)
        statusLbl.sizeToFit()
        contentView.addSubview(statusLbl)
        //
        
        //--------SEPARATORS
        var separator1 = UILabel(frame: CGRectMake(0, frame.size.height-60, frame.size.width, 60))
        separator1.backgroundColor = darkDarkGray
        contentView.addSubview(separator1)
        var separator2 = UILabel(frame: CGRectMake(0, 0, 100, frame.size.height))
        separator2.backgroundColor = darkDarkGray
        contentView.addSubview(separator2)
        var separator3 = UILabel(frame: CGRectMake(frame.size.width - 100, 0, 100, frame.size.height))
        separator3.backgroundColor = darkDarkGray
        contentView.addSubview(separator3)
        //------------------
        
        //--------------TIME
        var timeStmp = UILabel(frame: CGRectMake(100, 104, 160, 20))
        timeStmp.backgroundColor = UIColor(white: 0.25, alpha: 1)
        contentView.addSubview(timeStmp)
        var nstime : NSString = o.valueForKey("delivery").description
        var time: String = (nstime.substringFromIndex(11) as NSString).substringToIndex(5)
        var timeLbl = UILabel(frame: CGRectMake(100, 104, 160, 20))
        timeLbl.text = time;
        timeLbl.textColor = txtColor
        timeLbl.textAlignment = NSTextAlignment.Center
        timeLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        contentView.addSubview(timeLbl)
        //------------------
        
        var price: String = (o.valueForKey("total") as Float).description
        price += "0€"
        var priceLbl = UILabel(frame: CGRectMake(frame.width - 254, 100-34, 150, 30))
        priceLbl.text = price;
        priceLbl.textColor = txtColor
        priceLbl.textAlignment = NSTextAlignment.Right
        priceLbl.font = UIFont(name: "HelveticaNeue", size: 30)
        contentView.addSubview(priceLbl)
        
        //----STATUS-BUTTONS
        let status = o.valueForKey("status").description
        if status == "INIT" {
            var validateB = UIButton(frame: CGRectMake(frame.size.width - 96, 0, 84, 100))
            validateB.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0.2, alpha: 1)
            validateB.setTitle("V", forState: UIControlState.Normal)
            validateB.setTitleColor(txtColor, forState: UIControlState.Normal)
            validateB.addTarget(self, action: "validate", forControlEvents: UIControlEvents.TouchDown)
            contentView.addSubview(validateB)
            
            var discardB = UIButton(frame: CGRectMake(frame.size.width - 96, 104, 84, 20))
            discardB.backgroundColor = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
            discardB.setTitle("x", forState: UIControlState.Normal)
            discardB.setTitleColor(txtColor, forState: UIControlState.Normal)
            discardB.addTarget(self, action: "discard", forControlEvents: UIControlEvents.TouchDown)
            contentView.addSubview(discardB)
        }
        //------------------
        
        //----------NON-PAYE
        if o.valueForKey("total_unpayed") as Float > 0 {
            var payeStmp = UILabel(frame: CGRectMake(264, 104, frame.size.width - 364, 20))
            payeStmp.backgroundColor = UIColor(red: 0.8, green: 0.5, blue: 0, alpha: 1)
            contentView.addSubview(payeStmp)
            var payeLbl = UILabel(frame: CGRectMake(264, 104, frame.size.width - 364, 20))
            payeLbl.text = "NON PAYEE";
            payeLbl.textColor = txtColor
            payeLbl.textAlignment = NSTextAlignment.Center
            payeLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
            contentView.addSubview(payeLbl)
        }
        //------------------
    }
}
