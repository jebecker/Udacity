//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Jayme Becker on 6/17/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SentMemesCollectionViewController: UICollectionViewController {

    // MARK: - Properties/Outlets/Actions
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBAction func addMemeButtonPressed(_ sender: Any) {
        let mainMemeMeNavigationController = storyboard?.instantiateViewController(withIdentifier: "mainMemeNavigationController") as! UINavigationController
        present(mainMemeMeNavigationController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure the flow layout of the collection view
        let space: CGFloat = 3.0
        let dimensionHeight = (view.frame.size.height - (2 * space)) / 3.0
        let dimensionWidth = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSize(width: dimensionWidth, height: dimensionHeight)
        
    }
    
    // reload the data when the view re-appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView?.reloadData()
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return appDelegate.memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sentMemesCollectionViewCell", for: indexPath) as! SentMemesCollectionViewCell
    
        cell.imageView.image = appDelegate.memes[indexPath.row].memedImage
    
        return cell
    }
    
    // present the detail view controller when a user selectes a memed image
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = storyboard?.instantiateViewController(withIdentifier: "memeDetailViewController") as! MemeDetailViewController
        detailController.finalInit(memedImage: appDelegate.memes[indexPath.row].memedImage)
        navigationController?.pushViewController(detailController, animated: true)
    }

}


// MARK: - Custom Collection View Cell Class

class SentMemesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
}
