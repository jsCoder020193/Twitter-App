//
//  tweetCell.swift
//  Twitter
//
//  Created by SubbaLakshmi on 3/5/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class tweetCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetContent: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    var liked: Bool = true
    var retweeted: Bool = true
    var tweetID: Int = -1 //Set it to -1 so we know its not set yet
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//  Extra: Could have directly accessed tweetID and set it in HomeTableViewController
    func setTweetID(_ inputTweetID:Int){
        tweetID = inputTweetID
    }
    
//    Toggle the like button on the user interface
    func setLike(_ isLiked:Bool){
        liked = isLiked
        
        var likeCount: Int = Int(likeCountLabel.text!) ?? 0
        
        if(liked){
            likeButton.setImage(UIImage(named: "favor-icon-red"), for: UIControl.State.normal)
            likeCountLabel.textColor = UIColor.red
            
            likeCount += 1
        }else{
            likeButton.setImage(UIImage(named: "favor-icon"), for: UIControl.State.normal)
            likeCountLabel.textColor = UIColor.lightGray
            
            likeCount -= 1
        }
        
        likeCountLabel.text = String(likeCount)
    }
    
//    Toggle the like button on the user interface
    func setRetweet(_ isRetweeted:Bool){
        retweeted = isRetweeted
        
        var retweetCount: Int = Int(retweetCountLabel.text!) ?? 0

        if(retweeted){
            retweetButton.setImage(UIImage(named: "retweet-icon-green"), for: UIControl.State.normal)
            retweetCountLabel.textColor = UIColor.green
            retweetCount += 1
        }else{
            retweetButton.setImage(UIImage(named: "retweet-icon"), for: UIControl.State.normal)
            retweetCountLabel.textColor = UIColor.lightGray
            retweetCount -= 1
        }
        
        retweetCountLabel.text = String(retweetCount)
    }
    

//    toggle the like button using APIs
    @IBAction func toggleLikeButton(_ sender: Any) {
        let newLikeValue = !liked
        if(newLikeValue){
            // Call Twitter API- POST favorites/create + Show red like button on UI
            TwitterAPICaller.client?.likeTweet(tweetID: tweetID, success: {
                self.setLike(true)
            }, failure: { (error) in
                print("There was an error to like tweet \(error)")
            })
            
        }else{
            // Call Twitter API- POST favorites/create + Show gray like button on UI
            TwitterAPICaller.client?.unlikeTweet(tweetID: tweetID, success: {
                self.setLike(false)
            }, failure: { (error) in
                print("There was an error to un-like tweet \(error)")
            })
            
        }
    }
    
    @IBAction func toggleRetweetButton(_ sender: Any) {
        
        let newRetweetValue = !retweeted
        if(newRetweetValue){
            // Call Twitter API- POST statuses/retweet/:id + Show green retweet button on UI
            TwitterAPICaller.client?.retweet(tweetID: tweetID, success: {
                self.setRetweet(true)
            }, failure: { (error) in
                print("There was an error to retweet \(error)")
            })
            
        }else{
            // Call Twitter API- POST statuses/unretweet/:id + Show gray retweet button on UI
            TwitterAPICaller.client?.unretweet(tweetID: tweetID, success: {
                self.setRetweet(false)
            }, failure: { (error) in
                print("There was an error to un-retweet \(error)")
            })
            
        }
    }
    
}
