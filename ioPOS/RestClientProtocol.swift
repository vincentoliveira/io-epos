//
//  RestClientProtocol.swift
//  ioPOS
//
//  Created by Vincent Oliveira on 02/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import Foundation

protocol RestClientProtocol {
    func didRecieveResponse(results: NSDictionary)
    func didFailWithError(error: NSError!)
}