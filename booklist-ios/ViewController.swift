//
//  ViewController.swift
//  booklist-ios
//
//  Created by Adam Rackis on 5/4/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var mainLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func buttonClick(_ sender: Any) {
        self.mainLabel.text = "Ayyyyyy";
        
        
        
        var viewControllers = self.navigationController!.viewControllers
        _ = viewControllers.popLast()

        // Push targetViewController
        let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "loggedInMain")
        viewControllers.append(nextViewController)

        self.navigationController?.setViewControllers(viewControllers, animated: true)
        
        
        // let nextViewController = storyboard?.instantiateViewController(withIdentifier: "loggedInMain")
        // self.navigationController!.pushViewController(nextViewController, animated: true)
        


        
        //self.present(nextViewController, animated: true)
    }
    
}

