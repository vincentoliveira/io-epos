//
//  OrderListProtocol.swift
//  ioPOS
//
//  Created by Louis on 02/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import Foundation

protocol OrderListProtocol {
    func didRecieveResponse(results: NSDictionary)
    func didFailWithError(error: NSError!)
}