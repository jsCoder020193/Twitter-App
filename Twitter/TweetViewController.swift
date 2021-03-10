//
//  TweetViewController.swift
//  Twitter
//
//  Created by SubbaLakshmi on 3/6/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTextView.delegate = self
        
        tweetTextView.becomeFirstResponder()
        
        tweetTextView.layer.borderWidth = 1
        tweetTextView.layer.borderColor = UIColor.black.cgColor
        tweetTextView.layer.cornerRadius = 10
        tweetTextView.layer.masksToBounds = true
        
        profileImageView.layer.masksToBounds = true
         profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        
        setProfileImage()
    }
    
    @IBAction func cancelTweet(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postTweet(_ sender: Any) {
        if(!tweetTextView.text.isEmpty){
            TwitterAPICaller.client?.postTweet(tweetString: tweetTextView.text, success: {self.dismiss(animated: true, completion: nil)}, failure: { (error) in
                print("There was an error to post tweet \(error)")
            })
        }else{
//            self.dismiss(animated: true, completion: nil)
            let alertController = UIAlertController(title: "Error", message: "Please enter some text", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       // TODO: Check the proposed new text character count
       // Allow or disallow the new text
        
        // Set the max character limit
        let characterLimit = 140

        // Construct what the new text would be if we allowed the user's latest edit
        let newText = NSString(string: tweetTextView.text!).replacingCharacters(in: range, with: text)

        // TODO: Update Character Count Label

        characterCountLabel.text = "Characters Remaining: " + String(characterLimit - newText.count)
        if(characterLimit - newText.count < 20){
            characterCountLabel.textColor = UIColor.red
        }else{
            characterCountLabel.textColor = UIColor.green
        }
        
        // The new text should be allowed? True/False
        return newText.count < characterLimit
    }
    
//        Set the profile image
    func setProfileImage(){
        let url = "https://api.twitter.com/1.1/account/verify_credentials.json"
        
        TwitterAPICaller.client?.getDictionaryRequest(url: url, parameters: ["id": 1], success: { (accountDetailsDictionary) in
        
            let imageUrl = URL(string: ((accountDetailsDictionary["profile_image_url_https"] as? String)!))
            
            let data = try? Data(contentsOf: imageUrl!)
            
            if let imageData = data{
                self.profileImageView.image = UIImage(data: imageData)
            }
        }, failure: { (Error) in
                  print("Error getting account data \(Error)")
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
