//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by SubbaLakshmi on 3/5/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    
    var f: Int = 10
    var accountDetailsDictionary: NSDictionary!
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//      Call Set Account Details Method
        setAccountDetails()
        
        numberOfTweets = 20
//        loadTweets()
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTweets()
    }
    
    func setAccountDetails(){
        let url = "https://api.twitter.com/1.1/account/verify_credentials.json"
        
        TwitterAPICaller.client?.getDictionaryRequest(url: url, parameters: ["id": 1], success: { (result) in
  
            self.accountDetailsDictionary = result

        }, failure: { (Error) in
            print("Error getting account data \(Error)")
        })
    }
        
    @objc func loadTweets(){
        let tweetsUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetsUrl, parameters: myParams as [String : Any], success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets{
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }, failure: { (Error) in
            print("Could not get tweets \(Error)")
        })
    }
    
    func loadMoreTweets(){
        numberOfTweets = numberOfTweets + 20
        
        let tweetsUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetsUrl, parameters: myParams as [String : Any], success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets{
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
        }, failure: { (Error) in
            print("Could not get tweets")
        })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count{
            loadMoreTweets()
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    func getTimeDifference(_ inputDateTime: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM d HH:mm:ss Z yyyy"

        let date1 = dateFormatter.date(from: inputDateTime)!
        
        let date2 = Date()
                
        let calendar = Calendar.current
        let seconds = calendar.dateComponents([Calendar.Component.second], from: date1, to: date2).second
        let minutes = calendar.dateComponents([Calendar.Component.minute], from: date1, to: date2).minute
        let hours = calendar.dateComponents([Calendar.Component.hour], from: date1, to: date2).hour

//        print("\(hours!) hrs \(minutes!) mins \(seconds!) seconds ago")
        
        if(hours! > 0){
            return("\(hours!) hrs ago")
        }else if(minutes! > 0){
            return("\(minutes!) mins ago")
        }else{
            return("\(seconds!) seconds ago")
        }
            
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! tweetCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
//        Set the username label text
        cell.usernameLabel.text = user["name"] as? String
        
//        Set the tweetContent label text
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as? String
        
//        Set the time label text
        let createdAt = tweetArray[indexPath.row]["created_at"] as! String
        
        cell.timeLabel.text = getTimeDifference(createdAt)

//        Set the user profile image
        let imageUrl = URL(string: ((user["profile_image_url_https"] as? String)!))
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data{
            cell.profileImageView.image = UIImage(data: imageData)
        }
//        Set the tweetID property
        cell.setTweetID(tweetArray[indexPath.row]["id"] as! Int)
        
//        Set to red like button if true else gray for false
        cell.setLike(tweetArray[indexPath.row]["favorited"] as! Bool)
        
//        Set to green like button if true else gray for false
        cell.setRetweet(tweetArray[indexPath.row]["retweeted"] as! Bool)

//        Set the count of likes label
        cell.likeCountLabel.text = String(tweetArray[indexPath.row]["favorite_count"] as! Int)

//        Set the count of retweets label
        cell.retweetCountLabel.text = String(tweetArray[indexPath.row]["retweet_count"] as! Int)
        
        
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }


}
