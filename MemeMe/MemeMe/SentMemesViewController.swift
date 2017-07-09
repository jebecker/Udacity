//
//  SentMemesViewController.swift
//  MemeMe
//
//  Created by Jayme Becker on 6/18/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit

class SentMemesViewController: UIViewController {
   
    // MARK: - Properties/Outlets/Actions
    
    var dataSource: SentMemesTableViewDataSource?
    var delegate: SentMemesTableViewDelegate?
    
    @IBOutlet weak var tableView: UITableView!
   
    @IBAction func addMemeButtonWasPressed(_ sender: Any) {
        let mainMemeMeNavigationController = storyboard?.instantiateViewController(withIdentifier: "mainMemeNavigationController") as! UINavigationController
        present(mainMemeMeNavigationController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTable()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTable()
    }
    
    // custom method to to load all the necessary data and to prevent from code duplication
    func loadTable() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let delegate = SentMemesTableViewDelegate(appDelegate: appDelegate, viewController: self)
        let dataSource = SentMemesTableViewDataSource(appDelegate: appDelegate)
        self.delegate = delegate
        self.dataSource = dataSource
        tableView.delegate = delegate
        tableView.dataSource = dataSource
    }
    
}

// MARK: - Custom TableViewDelegate

class SentMemesTableViewDelegate: NSObject, UITableViewDelegate {
    
    var appDelegate: AppDelegate
    var viewController: UIViewController
    
    init(appDelegate: AppDelegate, viewController: UIViewController) {
        self.appDelegate = appDelegate
        self.viewController = viewController
    }

    // present the detail view controller when a user selectes a memed image
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = viewController.storyboard?.instantiateViewController(withIdentifier: "memeDetailViewController") as! MemeDetailViewController
        detailController.finalInit(memedImage: appDelegate.memes[indexPath.row].memedImage)
        viewController.navigationController?.pushViewController(detailController, animated: true)
        
    }
    
    
}

// MARK: - Custom TableViewDataSource

class SentMemesTableViewDataSource: NSObject, UITableViewDataSource {
    
    var appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentMemesTableViewCell") as! SentMemesTableViewCell
        
        cell.memeImageView.image = appDelegate.memes[indexPath.row].memedImage
        cell.memeTextLabel.text = "\(appDelegate.memes[indexPath.row].topText) \(appDelegate.memes[indexPath.row].bottomText)"
        
        return cell
    }
    
    
    
}

// MARK: - Custom UITableViewCell

class SentMemesTableViewCell: UITableViewCell {
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var memeTextLabel: UILabel!
    
}
