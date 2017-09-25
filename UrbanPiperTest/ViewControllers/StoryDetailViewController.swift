//
//  StoryDetailViewController.swift
//  UrbanPiperTest
//
//  Created by Gupta, Ajay - Ajay on 9/19/17.
//  Copyright © 2017 Gupta, Ajay - Ajay. All rights reserved.
//

import UIKit
import WebKit

class StoryDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,WKUIDelegate {

    @IBOutlet weak var storyTitleLbl: UILabel!
    @IBOutlet weak var storyUrlLbl: UILabel!
    @IBOutlet weak var creationTimeLbl: UILabel!
    @IBOutlet weak var numberOfCommentsBtn: UIButton!
    @IBOutlet weak var highlightedView1: UIView!
    @IBOutlet weak var highlightedView2: UIView!
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabelForWebView: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    var story:Story?
    var comments: [CommentDetails]?
    var detailModel: StoriesDetailResponseModel?
    var isCommentsLoadedFromBE: Bool?
    
    let cellHeightConstant: CGFloat = 70.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showHighlightedView(isHidden: true)
        
        self.commentsTableView.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
        // StoryDetail Delegate
        detailModel?.commentDelegate = self
        
        // Web view Delegate.
        webView.uiDelegate = self
        webView.isHidden = true
        loadingLabelForWebView.isHidden = true
        self.isCommentsLoadedFromBE = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        storyTitleLbl.text = story!.title!
        storyUrlLbl.text = story!.url!
        creationTimeLbl.text = "\(timeConvertor(story!.time!, with: Constants.dateFormate)) . \(story!.userName!)"
        numberOfCommentsBtn.setTitle(story!.commentsCount! + " COMMENTS", for: .normal)
        self.emptyCommentsCheck()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func commentsBtnTapped(_ sender: Any) {
        self.showHighlightedView(isHidden: true)
        webView.isHidden = true
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
        self.activityIndicator.isHidden = false
        loadingLabelForWebView.isHidden = true
        if self.isCommentsLoadedFromBE! {
            self.commentsTableView.isHidden = false
            self.commentsTableView.reloadData()
            self.activityIndicator.isHidden = true
        }
        self.emptyCommentsCheck()
    }
    
    @IBAction func articalBtnTapped(_ sender: Any) {
        OperationQueue.main.addOperation({ () -> Void in
            self.loadingLabelForWebView.isHidden = false
            if let _ = self.story?.url {
                self.loadingLabelForWebView.text = Constants.webViewLoadingMessage
            } else{
                self.loadingLabelForWebView.text = Constants.noArticalsFound
            }
            
            self.webView.isHidden = false
            self.showHighlightedView(isHidden: false)
            self.commentsTableView.isHidden = true
            self.activityIndicator.isHidden = true
        })
        
        if let url = URL(string: story!.url!) {
            let myRequest = URLRequest(url: url)
            webView.load(myRequest)
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
            
        } else {
            loadingLabelForWebView.text = Constants.noArticalMessage
        }
    }
    
    func emptyCommentsCheck(){
        if story!.commentsCount!.count == 1 {
            self.commentsTableView.isHidden = true
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            loadingLabelForWebView.isHidden = false
            loadingLabelForWebView.text = Constants.noCommentsFound
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let _ = object as? WKWebView else { return }
        guard let keyPath = keyPath else { return }
        guard let _ = change else { return }
        
        if keyPath == Constants.estimatedProgress {
            if Float(webView.estimatedProgress) > 0.5 {
                self.loadingLabelForWebView.isHidden = true
            }
        }
    }
    
    func showHighlightedView(isHidden: Bool){
        highlightedView2.isHidden = isHidden
        highlightedView1.isHidden = !isHidden
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func timeConvertor(_ time:String, with formate: String?)-> String {
        let date = Date(timeIntervalSince1970: TimeInterval(Double(time)!))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        if let formate = formate {
            dateFormatter.dateFormat = formate
        }
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.commentsCellIdentifier) as! CommentsTableViewCell
        cell.commentText.text =  comments![indexPath.row].cooment
        cell.timeAndUserDetail.text = timeConvertor((comments![indexPath.row].time)!, with: Constants.dateFormateWithTime) + " . " + (comments![indexPath.row].userName)!
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height:CGFloat = self.calculateHeight(inString: comments![indexPath.row].cooment!)
        return height + cellHeightConstant
    }
    
    func calculateHeight(inString:String) -> CGFloat {
        let messageString = inString
        let rect : CGRect = messageString.boundingRect(with: CGSize(width: 222.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        let requredSize:CGRect = rect
        
        return requredSize.height
    }
}

extension StoryDetailViewController: CommentsListResponseModelDelegate{
    func commentsArraySet(commentsArray: [CommentDetails]) {
        comments = commentsArray
        OperationQueue.main.addOperation({ () -> Void in
            
        self.commentsTableView.delegate = self
        self.commentsTableView.dataSource = self
        self.commentsTableView.reloadData()
            
        let button = self.view.viewWithTag(100) as? UIButton
            if !(button?.isSelected)! {
                self.commentsTableView.isHidden = false
            } else {
                self.commentsTableView.isHidden = true
            }
            
        self.loadingLabelForWebView.isHidden = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.isCommentsLoadedFromBE = true
        })
    }
}
