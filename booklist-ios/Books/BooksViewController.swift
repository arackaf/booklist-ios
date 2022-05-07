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
        
//        booksTableView.estimatedRowHeight = UITableView.automaticDimension
//        booksTableView.rowHeight = UITableView.automaticDimension
        
        search("")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookDisplayTableCell.identifier, for: indexPath) as! BookDisplayTableCell
        

        let book = books[indexPath.row]
        cell.titleLabel.text = book.title
        cell.junkLabel.isHidden = true
        
        if indexPath.row == 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                cell.junkLabel.isHidden = false
                cell.sizeToFit()
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
        let query = "https://mylibrary.onrender.com/graphql-public?query=%7BallBooks%7BBooks%7B_id%2Ctitle%2CsmallImage%2CsmallImagePreview%7D%7D%7D%0A";
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
