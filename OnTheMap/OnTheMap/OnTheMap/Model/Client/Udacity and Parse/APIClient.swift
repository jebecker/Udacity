//
//  APIClient.swift
//  OnTheMap
//
//  Created by Jayme Becker on 10/14/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import Foundation

class APIClient: NSObject {
    
    // MARK: - Properties
    var session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    // MARK: - Generic GET method for the PARSE API
    func taskForGETMethod(_ method: String, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let url = "\(Constants.ParseURL)\(method)?\(Constants.ParameterKeys.Limit)=100&\(Constants.ParameterKeys.Order)=-\(Constants.ParameterKeys.UpdatedAt)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.addValue(Constants.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
           
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(nil, NSError(domain: "taskForUGETMethod", code: 1, userInfo: userInfo))
            }
            
            // was there an error returned in the response
            guard (error == nil) else {
                sendError(error: "There was an error with the GET request \(error!)")
                return
            }
            
            // make sure we got a successfull 2xx response from the request
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode,
                httpStatusCode >= 200 && httpStatusCode <= 299 else {
                    sendError(error: "The request did not return a valid 2xx httpStatusCode for the GET REQUESTT")
                    return
            }
            
            // make sure there was actual data returned
            guard let data = data else {
                sendError(error: "There was no data returned in the GET request")
                return
            }
            
            self.convertDataWithCompletionHandler(data: data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: - Generic POST Method for Parse
    func taskForPOSTMethod(_ method: String, jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // build the URL and configure the request
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.ParseURL)\(method)")!)
        request.httpMethod = "POST"
        request.addValue(Constants.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        //request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: .utf8)
        
        // create the task
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // was there an error returned in the response
            guard (error == nil) else {
                sendError(error: "There was an error with your POST request \(error!)")
                return
            }
            
            // make sure we got a successfull 2xx response from the request
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode,
                httpStatusCode >= 200 && httpStatusCode <= 299 else {
                    sendError(error: "The request did not return a valid 2xx httpStatusCode for the POST")
                    return
            }
        
            // make sure there was actual data returned
            guard let data = data else {
                sendError(error: "There was no data returned in the POST request")
                return
            }
            
            self.convertDataWithCompletionHandler(data: data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        task.resume()
        return task
    }
    
    // MARK: - UDACITY GET Method
    // Method that gets the users first name and last name from the udacity API
    func taskForUdacityGETMethod(_ method: String, completionHandlerForUdacityGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.UdacityURL)\(method)")!)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForUdacityGET(nil, NSError(domain: "taskForUdacityGETMethod", code: 1, userInfo: userInfo))
            }
            
            // was there an error returned in the response
            guard (error == nil) else {
                sendError(error: "There was an error with the UDACITY GET request \(error!)")
                return
            }
            
            // make sure we got a successfull 2xx response from the request
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode,
                httpStatusCode >= 200 && httpStatusCode <= 299 else {
                    sendError(error: "The request did not return a valid 2xx httpStatusCode for the UDACITY GET REQUESTT")
                    return
            }
            
            // make sure there was actual data returned
            guard let data = data else {
                sendError(error: "There was no data returned in the UDACITY GET request")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            self.convertDataWithCompletionHandler(data: newData, completionHandlerForConvertData: completionHandlerForUdacityGET)
        }
        
        task.resume()
        return task
    }
    
    // MARK: - UDACITY DELETE SESSION
    //Method that logs out of the app by calling "DELETE" on the Udacity Session API
    func taskForUdacityDELETESession(_ method: String, completionHandlerForDELETE: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.UdacityURL)\(method)")!)
        request.httpMethod = "DELETE"
        
        // code from sample request
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForDELETE(nil, NSError(domain: "taskForUdacityDELETESession", code: 1, userInfo: userInfo))
            }
            
            // was there an error returned in the response
            guard (error == nil) else {
                sendError(error: "There was an error with deleting your UDACITY SESSION request \(error!)")
                return
            }
            
            // make sure we got a successfull 2xx response from the request
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode,
                httpStatusCode >= 200 && httpStatusCode <= 299 else {
                    sendError(error: "The request did not return a valid 2xx httpStatusCode for the DELETE UDACITY SESSION REQUEST")
                    return
            }
            
            // make sure there was actual data returned
            guard let data = data else {
                sendError(error: "There was no data returned in the DELTE UDACITY SESSION request")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            self.convertDataWithCompletionHandler(data: newData, completionHandlerForConvertData: completionHandlerForDELETE)
        }
        
        // start the request
        task.resume()
        return task
    }
    
    // MARK: - POST Method for the Udacity API
    func taskForUdacityPOSTMethod(_ method: String, jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // build the URL and configure the request since no parameters are needed for this method
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.UdacityURL)\(method)")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: .utf8)
        
        // make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPOST(nil, NSError(domain: "taskForUdacityPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // was there an error returned in the response
            guard (error == nil) else {
                sendError(error: "\(error!.localizedDescription)")
                return
            }
            
            // make sure we got a successfull 2xx response from the request
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode,
                httpStatusCode >= 200 && httpStatusCode <= 299 else {
                sendError(error: "Sorry, but either your username and/or password does not match! Please try again.")
                return
            }
            
            
            // make sure there was actual data returned
            guard let data = data else {
                sendError(error: "There was no data returned in the UDACITY SESSION request")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            self.convertDataWithCompletionHandler(data: newData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        // start the request
        task.resume()
        
        return task
    }
    
    // MARK: Helpers
    
    // substitute the key for the value that is contained within the method name
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    // method that takes in raw json and returns it in a usuable foundation object
    func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    
    class func sharedInstance() -> APIClient {
        struct Singleton {
            static var sharedInstance = APIClient()
        }
        
        return Singleton.sharedInstance
    }
    
    
}
