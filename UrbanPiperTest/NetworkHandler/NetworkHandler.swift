//
//  NetworkHandler.swift
//  UrbanPiperTest
//
//  Created by Gupta, Ajay - Ajay on 9/20/17.
//  Copyright © 2017 Gupta, Ajay - Ajay. All rights reserved.
//

import Foundation

struct Constants {
    static let prefixURLString = "https://hacker-news.firebaseio.com/v0/"
    static let suffixURLString = "?print=pretty"
    static let badAccessError = "Bad Access Error"
    static let storiesListSegueIdentifier = "StoriesList"
    static let errorMessageForLogin = "email/password can't be empty"
    static let estimatedProgress = "estimatedProgress"
    static let noArticalMessage = "No Articals for this Story"
    static let webViewLoadingMessage = "WebView rendering of the Artical URL"
    static let dateFormate = "d MMM, yyyy"
    static let dateFormateWithTime = "d MMM, yyyy HH:mm"
    static let commentsCellIdentifier = "commentsCell"
    static let storyListCellIdentifier = "StoryCell"
    static let storyDetailSegueIdentifier = "StoryDetailSegue"
    static let noCommentsFound = "No Comments found"
    static let noArticalsFound = "No Articals found"
 }

class NetworkHandler {
    // Clousure for returning the Result
    typealias FetchingCompletionBlock = (_ result : Any?) -> ()
    
    // Network Function for getting Json formate response
    func getResult(_  forStory:String ,complition:@escaping FetchingCompletionBlock){
        
        let urlString:NSString = NSString.init(format: "%@%@%@", Constants.prefixURLString,forStory,Constants.suffixURLString)
        
        let request = NSMutableURLRequest(url: NSURL(string: urlString as String)! as URL)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) in
            do {
                if let result = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary{
                    complition(result)
                }else {
                    let result = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as? NSArray
                    complition(result)
                }
                
                // Network Error Handling
                if let unwrappedError = error {
                    print("error=\(unwrappedError)")
                }
            } catch {
                print(Constants.badAccessError)
            }
        }
        task.resume()
    }
}
