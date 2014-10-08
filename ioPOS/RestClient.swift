//
//  RestClient.swift
//  ioPOS
//
//  Created by Vincent Oliveira on 02/10/14.
//  Copyright (c) 2014 InnovOrder. All rights reserved.
//

import Foundation

class RestClient: NSObject {
    let apiBaseUrl = "http://recette.innovorder.fr/api"
    
    var response: NSMutableData = NSMutableData()
    var delegate: RestClientProtocol?

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
        
        return (data as NSString).substringFromIndex(1).dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    //------------CALLS
    func checkAuth(email: String, password: String) {
        let apiUrl = "/restaurant/auth.json"
        let method = "POST"
        let params = ["email": email, "plainPassword": password]
        
        let url = generateUrl(apiUrl)
        let data = generateData(params);
        
        call(url, method: method, data: data)
    }
    
    func getOrders(restaurant: String) {
        let apiUrl = "/order/current.json"
        let method = "GET"
        
        let url = generateUrl(apiUrl, params: "token=" + restaurant)
        
        call(url)
    }
    
    func nextStatus(restaurant: String, cartId: String){
        let apiUrl = "/order/\(cartId)/next_status.json"
        let method = "PUT"
        let params = ["restaurant_token": restaurant]
        
        let url = generateUrl(apiUrl)
        let data = generateData(params);
        
        call(url, method: method, data: data)
    }
    func cancel(restaurant: String, cartId: String){
        let apiUrl = "/order/\(cartId)/cancel.json"
        let method = "PUT"
        let params = ["restaurant_token": restaurant]
        
        let url = generateUrl(apiUrl)
        let data = generateData(params);
        
        call(url, method: method, data: data)
    }
    //----------------
    
    
    func call(url: NSURL, method: String = "GET", data: NSData? = nil) {
        println("Call: \(method) \(url) with \(data)")

        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.HTTPBody = data
        request.timeoutInterval = 10.0
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)
        
        connection.start()
    }
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        println("Failed with error:\(error.localizedDescription)")
        delegate?.didFailWithError(error)
    }
    
    //NSURLConnection delegate method
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        //New request so we need to clear the data object
        self.response = NSMutableData()
    }
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        //Append incoming data
        self.response.appendData(data)
    }
    
    //NSURLConnection delegate method
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        //Finished receiving data and convert it to a JSON object
        var err: NSError
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(response,
            options:NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        delegate?.didRecieveResponse(jsonResult)
    }

}