//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Jayme Becker on 7/9/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    // MARK: - Properties/Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    var memedImage: UIImage?
    
    func finalInit(memedImage: UIImage){
        self.memedImage = memedImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = memedImage
        imageView.contentMode = .scaleAspectFit
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.popViewController(animated: true)
    }

}
