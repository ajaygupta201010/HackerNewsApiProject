//
//  TopStoriesViewController.swift
//  UrbanPiperTest
//
//  Created by Gupta, Ajay - Ajay on 9/19/17.
//  Copyright © 2017 Gupta, Ajay - Ajay. All rights reserved.
//

import UIKit

class TopStoriesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var storiesTableView: UITableView!
    @IBOutlet weak var updatedTimeLbl: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var model = StoriesListResponseModel()
    let detailModel = StoriesDetailResponseModel()
    var story:Story?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.networkCall()
        storiesTableView.delegate = self
        storiesTableView.dataSource = self
        model.storyDelegate = self
        storiesTableView.isHidden = true
        
        self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.activityIndicator.startAnimating()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.storiesArray.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell") as! StoriesListTableViewCell
        
        let date = Date(timeIntervalSince1970: TimeInterval(Double(String(describing: model.storiesArray[indexPath.row].time!))!))
        let timeSinceToday = Date().getTimeAgoSinceNow(date)
        let timeWithUserInfo = "\(timeSinceToday) . \(String(describing: model.storiesArray[indexPath.row].userName!))"
        
        cell.scoreLbl.text = model.storiesArray[indexPath.row].score
        cell.storyUrlLbl.text = model.storiesArray[indexPath.row].url
        cell.TitleLbl.text = model.storiesArray[indexPath.row].title
        cell.updatingTimeOfStory.text = timeWithUserInfo
        cell.numberOfComments.text = model.storiesArray[indexPath.row].commentsCount
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        story = model.storiesArray[indexPath.row]
        if let commentArray = story?.kidsArray{
            detailModel.parseCommentsArray(commentArray, itemNumber: (story?.id!)!)
        }
        self.performSegue(withIdentifier: "StoryDetailSegue", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StoryDetailSegue" {
            let detailVC = segue.destination as! StoryDetailViewController
            detailVC.story = story
            detailVC.detailModel = detailModel
        }
    }

}

extension TopStoriesViewController: StoriesListResponseModelDelegate{
    func storiesArraySet() {
        OperationQueue.main.addOperation({ () -> Void in
        self.storiesTableView.isHidden = false
        self.storiesTableView.reloadData()
        self.activityIndicator.stopAnimating()
        })
    }
}

extension Date {
    
  func getTimeAgoSinceNow(_ toDate:Date) -> String {
        var interval = Calendar.current.dateComponents([.year], from: toDate, to: self).year!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " year ago" : "\(interval)" + " years ago"
        }

        interval = Calendar.current.dateComponents([.month], from: toDate, to: self).month!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " month ago" : "\(interval)" + " months ago"
        }

        interval = Calendar.current.dateComponents([.day], from: toDate, to: self).day!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " day ago" : "\(interval)" + " days ago"
        }

        interval = Calendar.current.dateComponents([.hour], from: toDate, to: self).hour!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " hour ago" : "\(interval)" + " hours ago"
        }
    
        interval = Calendar.current.dateComponents([.minute], from: toDate, to: self).minute!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " minute ago" : "\(interval)" + " minutes ago"
        }
        
        return "a moment ago"
    }
}
