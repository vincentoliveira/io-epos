//
//  OrderTableViewCell.swift
//  ioPOS
//
//  Created by Louis on 03/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    //@IBOutlet weak var priceLabel: UILabel!
    let txtColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        
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
        self.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        frame.size.height *= 2
    }
    
    func setInfo(o: NSObject) {
        
        var price: String = (o.valueForKey("total") as Float).description
        /*if price[countElements(price) - 2] == "." {
            price += 0
        }*/
        price += "€"
        var priceLbl = UILabel(frame: CGRectMake(frame.size.width + 50, 5, 100, 20))
        priceLbl.backgroundColor = UIColor(red: 0.3, green: 0, blue: 0, alpha: 1)
        priceLbl.text = price;
        priceLbl.textColor = txtColor
        priceLbl.textAlignment = NSTextAlignment.Right
        contentView.addSubview(priceLbl)
        
        var id: String = "N°"
        id += o.valueForKey("id").description
        var idLbl = UILabel(frame: CGRectMake(0, 5, 100, 20))
        idLbl.backgroundColor = UIColor(red: 0, green: 0.3, blue: 0, alpha: 1)
        idLbl.text = id;
        idLbl.textColor = txtColor
        idLbl.textAlignment = NSTextAlignment.Left
        contentView.addSubview(idLbl)
        
        var nstime : NSString = o.valueForKey("delivery").description
        var time: String = (nstime.substringFromIndex(11) as NSString).substringToIndex(5)
        var timeLbl = UILabel(frame: CGRectMake(100, 5, 50, 20))
        timeLbl.backgroundColor = UIColor(red: 0, green: 0, blue: 0.3, alpha: 1)
        timeLbl.text = time;
        timeLbl.textColor = txtColor
        timeLbl.textAlignment = NSTextAlignment.Left
        contentView.addSubview(timeLbl)
        
        var separatorLbl = UILabel(frame: CGRectMake(0, frame.size.height-8, frame.size.width * 2, 20))
        separatorLbl.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        contentView.addSubview(separatorLbl)
    }
}
