//
//  OrderView.swift
//  ioPOS
//
//  Created by Louis on 06/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit

class OrderView: UIView {

    let txtColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */
    
    func setInfo(o: NSObject) {
        backgroundColor = txtColor
    }
}
