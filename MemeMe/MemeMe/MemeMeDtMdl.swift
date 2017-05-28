//
//  MemeMeDtMdl.swift
//  MemeMe
//
//  Created by Jayme Becker on 5/28/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import Foundation
import UIKit


struct Meme {
    
    let topText: String
    let bottomText: String
    let originalImage: UIImage
    let memedImage: UIImage
    
    // custom initializer
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
