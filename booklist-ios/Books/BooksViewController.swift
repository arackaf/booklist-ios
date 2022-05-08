//
//  BooksViewController.swift
//  booklist-ios
//
//  Created by Adam Rackis on 5/4/22.
//

import UIKit

class BooksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var booksTableView: UITableView!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var dumbButton: UIButton!
    
    var books: [BookListItemModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        booksTableView.dataSource = self
        booksTableView.delegate = self
        
        let mainBookTableCell = UINib(nibName: BookDisplayTableCell.identifier, bundle: nil)
        
        navigationItem.backButtonTitle = "Books"
        booksTableView.register(mainBookTableCell, forCellReuseIdentifier: BookDisplayTableCell.identifier)
        
        booksTableView.layoutMargins = UIEdgeInsets.zero
        booksTableView.separatorInset = UIEdgeInsets.zero
        
        booksTableView.estimatedRowHeight = UITableView.automaticDimension
        booksTableView.rowHeight = UITableView.automaticDimension
        
        search("")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookDisplayTableCell.identifier, for: indexPath) as! BookDisplayTableCell
        
        //cell.translatesAutoresizingMaskIntoConstraints = false
        //cell.contentView.translatesAutoresizingMaskIntoConstraints = false
        let book = books[indexPath.row]
        cell.titleLabel.text = book.title
        //cell.junkLabel.isHidden = true
        
        //let coverImageView = UIImageView()
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageName = documentDirectory.appendingPathComponent("img1.jpg")
        
        let imgData = try? Data(contentsOf:imageName)
        if let imageOnDisk = UIImage(data:imgData!) {
            //DispatchQueue.main.sync {
            

            let img = UIImageView()
            //img.translatesAutoresizingMaskIntoConstraints = true
            img.contentMode = .left
            img.image = imageOnDisk
            
            //img.frame = CGRect(x: 0, y: 0, width: imageOnDisk.size.width, height: imageOnDisk.size.height)
            //img.frame.size = imageOnDisk.size
            cell.coverContainer.addArrangedSubview(img)
            //cell.coverContainerHeight.constant = imageOnDisk.size.height
        }
        
        // -----------------------------------------------------------------------------------------
        
        
        if let mobileImage = book.mobileImage,
           let urlToDownload = URL(string: mobileImage) {

            
            

            URLSession.shared.downloadTask(with: urlToDownload) { (tempFileUrl, response, error) in

                if let imageTempFileUrl = tempFileUrl {
                    do {
                        let imageName = documentDirectory.appendingPathComponent(book._id + ".jpg")
                        let imageData = try Data(contentsOf: imageTempFileUrl)
                        try imageData.write(to: imageName)

                        
                        let imgData = try? Data(contentsOf:imageName)
                        guard let imageOnDisk = UIImage(data:imgData!) else {
                            print("Couldn't get image")
                            return
                        }
                        
                        DispatchQueue.main.sync {
                            
                            print("About to remove")
                            for item in cell.coverContainer.arrangedSubviews {
                                print("removing")
                                item.removeFromSuperview()
                            }
                            cell.coverContainer.removeFromSuperview()
                            //cell.coverContainerHeight.constant = 150
                            //cell.layoutSubviews()
                            //cell.coverContainer.sizeToFit()
                            //cell.sizeToFit()
                            //cell.coverContainer.removeFromSuperview()
                            cell.sizeToFit()
//
                            //let img = UIImageView()
                            //img.contentMode = .scaleAspectFit

                            //img.image = imageOnDisk

                            //img.frame = CGRect(x: 0, y: 0, width: imageOnDisk.size.width, height: imageOnDisk.size.height)
                            //cell.coverContainer.addSubview(img)
//
                            //NSLayoutConstraint.activate([
                                //img.topAnchor.constraint(equalTo: cell.coverContainer.topAnchor),
                                //img.leadingAnchor.constraint(equalTo: cell.coverContainer.leadingAnchor),
                                //img.trailingAnchor.constraint(equalTo: cell.coverContainer.trailingAnchor),
                                //img.bottomAnchor.constraint(equalTo: cell.coverContainer.bottomAnchor),
                                //img.heightAnchor.constraint(equalToConstant: imageOnDisk.size.height),
                            //])
                            
                            //cell.coverImageView.image = imageOnDisk
                            //cell.coverImageView.frame = CGRect(x: 0, y: 0, width: imageOnDisk.size.width, height: imageOnDisk.size.height)
                        }
                    } catch {
                        print("Error")
                    }
                } else {
                    print("Top error")
                }
            }.resume()
        }
        
        
        // ---------------------------------------------------------------------------------------------
        
        
        
        
        


        
        //cell.coverContainer.addSubview(coverImageView)
        //cell.coverContainer.sizeToFit()
        cell.sizeToFit()

        //cell.coverContainer.sizeToFit()
        
        if indexPath.row == 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                //cell.junkLabel.isHidden = false
                //cell.sizeToFit()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookDetails = BookDetailsView();
        self.navigationController!.pushViewController(bookDetails, animated: true);
    }
    
    func search(_ text: String) {
        let query = "https://mylibrary.onrender.com/graphql-public?query=%7BallBooks%7BBooks%7B_id%2Ctitle%2CmobileImage%2CmobileImagePreview%7D%7D%7D%0A";
        let url = URL(string: query)!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any],
               let data = json["data"] as? [String:Any],
               let querySet = data["allBooks"] as? [String:Any],
               let results = querySet["Books"] as? [[String:Any]] {
                
                self.books = results.map { BookListItemModel($0) }
                
                DispatchQueue.main.sync {
                    self.booksTableView.reloadData()
                }
            } else {
                print("oops")
            }
            
        }

        task.resume()
    }
    
    @IBAction func onDumbClick(_ sender: Any) {
        //  self.topLabel.text = "Ayoooooo"
        
        let url = URL(string: "https://mylibrary.io/graphql-public?query=%7BallBooks%7BBooks%7B_id%2Ctitle%2CsmallImage%7D%7D%7D%0A%0A")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
    }
}
