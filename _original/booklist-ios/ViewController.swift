//
//  ViewController.swift
//  booklist-ios
//
//  Created by Adam Rackis on 5/4/22.
//

import UIKit
import temp_pkg
import temp2

struct Login: Codable {
    let email: String
    let password: String
}

struct GraphqlQueryRequest: Codable {
    let loginToken: String
    let query: String
}

class ViewController: UIViewController {

    @IBOutlet var mainLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let junk2 = temp2.JunkStruct(val: "TEMP2")
        
        let inst = temp_pkg.JunkClass()
        self.mainLabel.text = inst.val + " " + junk2.val

        
        
        let url = URL(string: "https://d193qjyckdxivp.cloudfront.net/small-covers/573d1b97120426ef0078aa92/f09c52a1-b0ce-4557-8c4c-3d12e38d226b.jpg")!
        let loginUrl = URL(string: "https://mylibrary.onrender.com/login-ios")!
        
        var request = URLRequest(url: url)
        
        let login = Login(email: "tester1", password: "password");
                
        // Convert model to JSON data
        guard let loginRequestPacket = try? JSONEncoder().encode(login) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        
        var loginTokenRequest = URLRequest(url: loginUrl)
        loginTokenRequest.httpMethod = "POST"
        loginTokenRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        loginTokenRequest.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        loginTokenRequest.httpBody = loginRequestPacket
        
        URLSession.shared.dataTask(with: loginTokenRequest) { data, response, error in
            print("ehhhhh")
            var loginToken: String? = ""
            guard error == nil else {
                print("Error: error calling POST")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("HTTP request not 200")
                return
            }
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON object")
                    print("\n\n")
                    print(data)
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    print("Error: Cannot convert JSON object to Pretty JSON data")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Couldn't print JSON in String")
                    return
                }
                
                guard let respData: [String: Any] = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("No serialization :(")
                    return
                }
                
                loginToken = respData["loginToken"] as? String
                guard let _ = loginToken else {
                    print("no login token")
                    return
                }
                
                print(loginToken);
                
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
                
                
                
                
                
            let query = """
            {
              allBooks {
                Books {
                  _id
                  title
                  smallImage
                  smallImagePreview
                }
              }
            }
            """
        
            let queryPacket = GraphqlQueryRequest(loginToken: loginToken!, query: query);
                        
            // Convert model to JSON data
            guard let queryRequestPacket = try? JSONEncoder().encode(queryPacket) else {
                print("Error: Trying to convert model to JSON data")
                return
            }
            let graphqlUrl = URL(string: "https://mylibrary.onrender.com/graphql-ios")!
            var graphqlRequest = URLRequest(url: graphqlUrl)
            graphqlRequest.httpMethod = "POST"
            graphqlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
            graphqlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
            graphqlRequest.httpBody = queryRequestPacket
                
        
            
        
            URLSession.shared.dataTask(with: graphqlRequest) { (data, response, error) in
                print("graphql callback")
                guard error == nil else {
                    print("Error: error calling POST")
                    print(error!)
                    return
                }
                guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                    print("HTTP request not 200")
                    return
                }

                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any],
                   let data = json["data"] as? [String:Any],
                   let querySet = data["allBooks"] as? [String:Any],
                   let results = querySet["Books"] as? [[String:Any]] {
                    
                   let books = results.map { BookListItemModel($0) }
                   
                    print(books)
                } else {
                    print("couldn't serialize books")
                }
            }.resume()
        
                
                
                
                
                
                
                
                
                
            
        }.resume()
            
        
        
        
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
    
    @IBAction func loadCollectionView(_ sender: Any) {
        var viewControllers = self.navigationController!.viewControllers
        _ = viewControllers.popLast()

        // Push targetViewController
        let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "loggedInMain")
        viewControllers.append(nextViewController)

        self.navigationController?.setViewControllers(viewControllers, animated: true)
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

