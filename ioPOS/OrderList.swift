//
//  OrderList.swift
//  ioPOS
//
//  Created by Louis on 02/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import UIKit

class OrderList: NSObject {
    let apiBaseUrl = "http://recette.innovorder.fr/api"
    
    var response: NSMutableData = NSMutableData()
    var delegate: OrderListProtocol?
    
    func generateUrl(apiUrl: String, params: String? = nil) -> NSURL {
        var url = apiBaseUrl + apiUrl
        
        if let p = params {
            url += "?" + p
        }
        
        return NSURL(string: url)
    }
    
    func generateData(params: NSDictionary) -> NSData {
        var data = ""
        for (key, value) in params {
            data += "&\(key)=\(value)"
        }
        
        
        NSLog("Data: %@", data)
        
        return (data as NSString).substringFromIndex(1).dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func checkAuth(restaurant: String) {
        let apiUrl = "/order/cart/:id.json"
        let method = "GET"
        let params = ["restaurant": restaurant]
        
        let url = generateUrl(apiUrl)
        let data = generateData(params);
        
        call(url, data: data, method: method)
    }

        
    func call(url: NSURL, data: NSData, method: String = "GET") {
        println("Call: \(method) \(url) with \(data)")
        
        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.HTTPBody = data
        request.timeoutInterval = 10.0;
        
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)
        
        connection.start()
    }
}
