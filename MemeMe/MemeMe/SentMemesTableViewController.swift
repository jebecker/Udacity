//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Jayme Becker on 6/17/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit
import Foundation

class SentMemesTableViewController: UITableViewController {
    
    var memes: [Meme]!
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "tableViewToMemeEditor", sender: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        //tableView.delegate = SentMemesTableViewDelegate()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return memes.count
    }
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentMemesTableViewCell") as! SentMemesTableViewCell
        
        cell.memeImageView.image = memes[indexPath.row].memedImage
        cell.memeLabel.text = "\(memes[indexPath.row].topText) \(memes[indexPath.row].bottomText)"
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    
}


// MARK : - Table View Delegate Methods

//class SentMemesTableViewDelegate: NSObject, UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//    }
//}


// MARK: - Custom table view cell
class SentMemesTableViewCell: UITableViewCell {
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var memeLabel: UILabel!
    
}
