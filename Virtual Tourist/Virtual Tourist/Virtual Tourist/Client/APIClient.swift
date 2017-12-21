//
//  APIClient.swift
//  Virtual Tourist
//
//  Created by Jayme Becker on 12/10/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import Foundation

class APIClient: NSObject {
    
    // MARK: - Properties
    var session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    // Method to fire off the GET request for photos at the specified Pins latitude and longitude
    func getPhotosByLatitudeAndLongitude(latitude: Double, longitude: Double, randomPage: Int, completionHandlerForFlickrGETPHotos: @escaping (_ result: [NSData]?, _ error: String? ) -> Void ) {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude: latitude, longitude: longitude),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.numberOfPages,
            Constants.FlickrParameterKeys.Page: "\(randomPage)"
        ]
        
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String:AnyObject]))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // check to see if there was an error returned in the response
            guard error == nil else {
                completionHandlerForFlickrGETPHotos(nil, "There was an error returned in the request: \(error!)")
                return
            }
            
            // make sure we got a successfull 2xx response from the request
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode,
                httpStatusCode >= 200 && httpStatusCode <= 299 else {
                    completionHandlerForFlickrGETPHotos(nil, "The request did not return a valid 2xx httpStatusCode for the the GET photos search method")
                    return
            }
            
            // grab the data returned
            guard let data = data else {
                completionHandlerForFlickrGETPHotos(nil, "We could not unwrap the data returned!!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the returned data!")
                completionHandlerForFlickrGETPHotos(nil, "Could not parse the returned data!")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let status = parsedResult[Constants.FlickrResponseKeys.Status] as? String, status == Constants.FlickrResponseValues.OKStatus else {
                completionHandlerForFlickrGETPHotos(nil, "Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandlerForFlickrGETPHotos(nil, "Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            // get the array of photos from the dictionary
            guard let photos = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                completionHandlerForFlickrGETPHotos(nil, "Could get the array of photos from the response")
                return

            }
            
            // return if there are no photos returned
            if photos.count == 0 {
                completionHandlerForFlickrGETPHotos(nil, "There were no photos returned!")
            }
            
            // go through all of the photos returned and grab the urls returned and convert that url into image Data
            let photoData = photos.map { (photo) -> NSData in
                if let url = photo[Constants.FlickrResponseKeys.MediumURL] as? String,
                    let imageURL = URL(string: url),
                    let imageData = NSData(contentsOf: imageURL) {
                        return imageData
                }
                
                // shouldn't get here but just in case
                return NSData()
            }
            
            // return the array of photo data through the completion handler
            completionHandlerForFlickrGETPHotos(photoData, nil)
        }
        
        // start the task
        task.resume()
    }
    
    // create a 'region' determined by the pins lat and lon
    private func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    class func sharedInstance() -> APIClient {
        struct Singleton {
            static var sharedInstance = APIClient()
        }
        
        return Singleton.sharedInstance
    }
}
