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

        let url = URL(string: "https://d193qjyckdxivp.cloudfront.net/small-covers/573d1b97120426ef0078aa92/f09c52a1-b0ce-4557-8c4c-3d12e38d226b.jpg")!
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
            if  let data = data,
                let image = UIImage(data: data) {
                print(image.size)
            
                DispatchQueue.main.sync {
                    self.image1.image = image
                    self.image1.frame.size = image.size
                }
            }
        }
        dataTask.resume()
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageName = documentDirectory.appendingPathComponent("img1.jpg")
        
        let urlToDownload = URL(string: "https://d193qjyckdxivp.cloudfront.net/small-covers/573d1b97120426ef0078aa92/5b848e95-a579-4bee-8a40-53871ea45dee.jpg")!
        
        print("Attempting:", urlToDownload)
        URLSession.shared.downloadTask(with: urlToDownload) { (tempFileUrl, response, error) in
            print("CALLBACK")
            if let imageTempFileUrl = tempFileUrl {
                do {
                    let imageData = try Data(contentsOf: imageTempFileUrl)
                    try imageData.write(to: imageName)
                    print("DONE!!!")
                    print(imageName)
                    
                    print("----")

                    
                    let imgData = try? Data(contentsOf:imageName)
                    guard let imageOnDisk = UIImage(data:imgData!) else {
                        print("Couldn't get image")
                        return
                    }
                    
                    DispatchQueue.main.sync {
                        self.image2.image = imageOnDisk
                        self.image2.frame.size = imageOnDisk.size
                    }
                } catch {
                    print("Error")
                }
            } else {
                print("Top error")
            }
        }.resume()
        
        //print(documentDirectory)
    }

    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    
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

