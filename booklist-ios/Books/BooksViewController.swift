//
//  BooksViewController.swift
//  booklist-ios
//
//  Created by Adam Rackis on 5/4/22.
//

import UIKit

class BooksViewController: UIViewController {

    @IBOutlet var topLabel: UILabel!
    @IBOutlet var dumbButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onDumbClick(_ sender: Any) {
        self.topLabel.text = "Ayoooooo"
    }
    

}
