//
//  ScaledImageView.swift
//  booklist-ios
//
//  Created by Adam Rackis on 5/7/22.
//

import UIKit

class ScaledImageView: UIImageView {

    override var intrinsicContentSize: CGSize {

        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
        
            print("Calculated!")
            return CGSize(width: myImageWidth, height: myImageHeight)

        }

        return CGSize(width: -1.0, height: -1.0)
    }

}
