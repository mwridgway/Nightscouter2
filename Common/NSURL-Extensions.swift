//
//  NSURL-Extensions.swift
//
//

import Foundation

//  MARK: NSURL Validation
//  Modified by Peter
//  Created by James Hickman on 11/18/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
public extension NSURL
{
    public struct ValidationQueue {
        public static var queue = NSOperationQueue()
    }
    
    enum ValidationError: ErrorType {
        case Empty(String)
        case OnlyPrefix(String)
        case ContainsWhitespace(String)
        case CouldNotCreateURL(String)
    }
    
    public class func validateUrl(urlString: String?) throws -> NSURL {
        // Description: This function will validate the format of a URL, re-format if necessary, then attempt to make a header request to verify the URL actually exists and responds.
        // Return Value: This function has no return value but uses a closure to send the response to the caller.
        var formattedUrlString : String?
        
        // Ignore Nils & Empty Strings
        if (urlString == nil || urlString == "")
        {
            throw ValidationError.Empty("Url String was empty")
        }
        
        // Ignore prefixes (including partials)
        let prefixes = ["http://www.", "https://www.", "www."]
        for prefix in prefixes
        {
            if ((prefix.rangeOfString(urlString!, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil)) != nil){
                throw ValidationError.OnlyPrefix("Url String was prefix only")
            }
        }
        
        // Ignore URLs with spaces (NOTE - You should use the below method in the caller to remove spaces before attempting to validate a URL)
        let range = urlString!.rangeOfCharacterFromSet(NSCharacterSet.whitespaceCharacterSet())
        if let _ = range {
            throw ValidationError.ContainsWhitespace("Url String cannot contain whitespaces")
        }
        
        // Check that URL already contains required 'http://' or 'https://', prepend if it does not
        formattedUrlString = urlString
        if (!formattedUrlString!.hasPrefix("http://") && !formattedUrlString!.hasPrefix("https://"))
        {
            formattedUrlString = "https://"+urlString!
        }
        
        guard let finalURL = NSURL(string: formattedUrlString!) else {
            throw ValidationError.CouldNotCreateURL("Url could not be created.")
        }
        
        return finalURL
    }
    
    public class func validateUrl(urlString: String?, completion:(success: Bool, urlString: String? , error: NSString) -> Void)
    {
        let parsedURL = try? validateUrl(urlString)
        
        // Check that an NSURL can actually be created with the formatted string
        if let validatedUrl = parsedURL //NSURL(string: formattedUrlString!)
        {
            // Test that URL actually exists by sending a URL request that returns only the header response
            let request = NSMutableURLRequest(URL: validatedUrl)
            request.HTTPMethod = "HEAD"
            ValidationQueue.queue.cancelAllOperations()
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: ValidationQueue.queue)
            
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                
                let url = request.URL!.absoluteString
                
                // URL failed - No Response
                if (error != nil)
                {
                    completion(success: false, urlString: url, error: "The url: \(url) received no response")
                    return
                }
                
                // URL Responded - Check Status Code
                if let urlResponse = response as? NSHTTPURLResponse
                {
                    if ((urlResponse.statusCode >= 200 && urlResponse.statusCode < 400) || urlResponse.statusCode == 405) // 200-399 = Valid Responses, 405 = Valid Response (Weird Response on some valid URLs)
                    {
                        completion(success: true, urlString: url, error: "The url: \(url) is valid!")
                        return
                    }
                    else // Error
                    {
                        completion(success: false, urlString: url, error: "The url: \(url) received a \(urlResponse.statusCode) response")
                        return
                    }
                }
            })
            
            task.resume()
        }
    }
}

// Created by Pete
// inspired by https://github.com/ReactiveCocoa/ReactiveCocoaIO/blob/master/ReactiveCocoaIO/NSURL%2BTrailingSlash.m
// MARK: Detect and remove trailing forward slash in URL.
extension NSURL {
    var hasTrailingSlash: Bool {
        return self.absoluteString.hasSuffix("/")
    }
    
    var URLByAppendingTrailingSlash: NSURL? {
        if !self.hasTrailingSlash, let newURL = NSURL(string: self.absoluteString.stringByAppendingString("/")){
            return newURL
        }
        
        return nil
    }
    
    var URLByDeletingTrailingSlash: NSURL? {
        let urlString = self.absoluteString
        let stepBackOne = urlString.endIndex.advancedBy(-1)
        
        if self.hasTrailingSlash, let newURL = NSURL(string: urlString.substringToIndex(stepBackOne)) {
            return newURL
        }
        
        return nil
    }
    
}