//
//  FilterButton.swift
//  ioPOS
//
//  Created by Louis on 10/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit

class FilterButton: UIButton {
    
    var white: UIImageView?
    var gray: UIImageView?
    
    var parent: TitleViewController?
    var title = "All"
    
    var toggled: Bool = false
    
    func initialize(title: String) {
        self.title = title
        
        var h: CGFloat = 30
        var w: CGFloat = 30
        if title == "All" || title == "No-pay" || title == "History" { w = 40 }
        if title == "All" { h = 24 }
        var x = frame.width / 2 - w / 2
        var y = frame.height / 2 - h / 2
        white = UIImageView(frame: CGRectMake(x, y, w, h))
        gray = UIImageView(frame: CGRectMake(x, y, w, h))
        white?.image = UIImage(named: "Icone_\(title).png")
        gray?.image = UIImage(named: "Icone_\(title)-Gray.png")
        white?.hidden = true
        addSubview(gray!)
        addSubview(white!)
        
        if (frame.origin.y != 0) {
            var sep = UILabel(frame: CGRectMake(1, 0, frame.width - 2, 1))
            sep.backgroundColor = UIColor(white: 1, alpha: 0.3)
            addSubview(sep)
        }
        
        addTarget(parent, action: "untoggleAll", forControlEvents: UIControlEvents.TouchDown)
        addTarget(self, action: "toggle", forControlEvents: UIControlEvents.TouchDown)
        if (title == "All") { toggle() }
    }

    func toggle() {
        toggled = true
        white?.hidden = false
        gray?.hidden = true
    }
    
    func untoggle() {
        toggled = false
        gray?.hidden = false
        white?.hidden = true
    }
}
