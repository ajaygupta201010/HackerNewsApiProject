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
    @IBOutlet weak var EmptyLabel: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    var story:Story?
    var comments: [CommentDetails]?
    var detailModel: StoriesDetailResponseModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showHighlightedView(isHidden: true)
        self.commentsTableView.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        detailModel?.commentDelegate = self
        // Do any additional setup after loading the view.
        webView.uiDelegate = self
        webView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        storyTitleLbl.text = story!.title!
        storyUrlLbl.text = story!.url!
        creationTimeLbl.text = "\(timeConvertor(story!.time!, with: "d MMM, yyyy")) . \(story!.userName!)"
        numberOfCommentsBtn.setTitle(story!.commentsCount! + " COMMENTS", for: .normal)
        if story!.commentsCount!.count > 0 {
            self.commentsTableView.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func commentsBtnTapped(_ sender: Any) {
       self.showHighlightedView(isHidden: true)
        webView.isHidden = true
        self.commentsTableView.isHidden = false
    }
    
    @IBAction func articalBtnTapped(_ sender: Any) {
        OperationQueue.main.addOperation({ () -> Void in
        self.EmptyLabel.text = "WebView rendering of the Artical URL"
        self.webView.isHidden = false
        self.showHighlightedView(isHidden: false)
        self.commentsTableView.isHidden = true
        self.activityIndicator.isHidden = true
        (sender as! UIButton).tag = 100
        print("hi")
        })
        
        if let url = URL(string: story!.url!) {
            let myRequest = URLRequest(url: url)
            webView.load(myRequest)
            EmptyLabel.isHidden = true
        } else {
            EmptyLabel.text = "No Articals for this Story"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell") as! CommentsTableViewCell
        cell.commentText.text =  comments![indexPath.row].cooment
        cell.timeAndUserDetail.text = timeConvertor((comments![indexPath.row].time)!, with: "d MMM, yyyy HH:mm") + " . " + (comments![indexPath.row].userName)!
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
                self.commentsTableView.isHidden = true
            } else {
                self.commentsTableView.isHidden = false
            }
            
        self.EmptyLabel.isHidden = true
        self.activityIndicator.stopAnimating()
        })
    }
}
