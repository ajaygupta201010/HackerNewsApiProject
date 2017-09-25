//
//  StoriesListResponseModel.swift
//  UrbanPiperTest
//
//  Created by Gupta, Ajay - Ajay on 9/20/17.
//  Copyright © 2017 Gupta, Ajay - Ajay. All rights reserved.
//

import UIKit

protocol StoriesListResponseModelDelegate:class {
    func storiesArraySet()
}

class StoriesListResponseModel {
    let networkHandler:NetworkHandler = NetworkHandler()
    var itemIDArray: NSArray = NSArray()
    weak var storyDelegate: StoriesListResponseModelDelegate?
    
    var storiesArray: [Story] = []
    
    var resultArray :[Story] = [] {
        didSet{
            storyDelegate?.storiesArraySet()
        }
    }
    
    func networkCall(){
        networkHandler.getResult("topstories.json") { (result : Any?) in
            if result is NSArray{
                var counter = 15
                self.itemIDArray = result as! NSArray
                if self.itemIDArray.count > 100 {
                    self.itemIDArray = self.itemIDArray.subarray(with: NSMakeRange(0, 105)) as NSArray
                }
                for item in self.itemIDArray{
                    let itemNumber = String(describing: item)
                    self.networkHandler.getResult("item/\(itemNumber).json", complition: { (internalResult: Any?) in
                        let itemDict = internalResult as! NSDictionary
                        self.parseResult(itemDict)
                        
                        if self.storiesArray.count ==  counter {
                            self.resultArray = self.storiesArray
                            counter += 15
                        }
                    })
                }
            }
        }
    }
    
    func parseResult(_ itemDictionarty: NSDictionary){
        var id = ""
        var score = ""
        var time = ""
        var title = ""
        var url = ""
        var userName = ""
        var commentsCount = ""
        var kidsArray: NSArray = NSArray()
        
        if let result = itemDictionarty["kids"]{
            kidsArray =  result as! NSArray
        }
        if let result = itemDictionarty["id"]{
            id = String(describing: result)
        }
        if let result = itemDictionarty["score"]{
            score = String(describing: result)
        }
        if let result  = itemDictionarty["time"] {
            time = String(describing: result)
        }
        if let result = itemDictionarty["title"] {
            title = String(describing: result)
        }
        if let result = itemDictionarty["url"] {
            url = String(describing: result)
        }
        if  let result = itemDictionarty["by"]{
            userName = String(describing: result)
        }
        if let result = itemDictionarty["descendants"]{
            commentsCount = String(describing: result)
        }
        
        let story =  Story.init(id:id, score: score, time: time, title: title, url: url, userName: userName, commentsCount: commentsCount, kidsArray: kidsArray)
        storiesArray.append(story)
    }
}

protocol CommentsListResponseModelDelegate:class {
    func commentsArraySet(commentsArray: [CommentDetails])
}

class StoriesDetailResponseModel {
    let networkHandler:NetworkHandler = NetworkHandler()
    weak var commentDelegate: CommentsListResponseModelDelegate?
    
    var commentsArray: [CommentDetails] = [] {
        didSet{
            commentDelegate?.commentsArraySet(commentsArray: commentsArray)
        }
    }
    
    
    func parseCommentsArray(_ kidsArray: NSArray, itemNumber:String) {
        var arrayOfComments: [CommentDetails] = []
        for itemNumber in kidsArray{
            self.networkHandler.getResult("item/\(itemNumber).json", complition: { (internalResult: Any?) in
                let itemDict = internalResult as! NSDictionary
                
                var userName = ""
                var comment = ""
                var time = ""
                
                if let result = itemDict["by"]{
                    userName = String(describing: result)
                }
                if let result = itemDict["text"]{
                    comment = String(describing: result)
                }
                if let result = itemDict["time"]{
                    time = String(describing: result)
                }
                
                let commentDetail = CommentDetails.init(userName: userName, cooment: comment, time: time)
                arrayOfComments.append(commentDetail)
                if arrayOfComments.count == kidsArray.count{
                    self.commentsArray = arrayOfComments
                }
            })
        }
    }
}

struct Story {
    let id: String?
    let score: String?
    let time: String?
    let title: String?
    let url: String?
    let userName: String?
    let commentsCount: String?
    let kidsArray: NSArray?
}

struct CommentDetails {
    let userName: String?
    let cooment: String?
    let time: String?
}
