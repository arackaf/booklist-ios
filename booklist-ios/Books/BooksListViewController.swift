//
//  BooksListViewController.swift
//  booklist-ios
//
//  Created by Adam Rackis on 5/8/22.
//

import UIKit

class BooksListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var booksCollectionView: UICollectionView!
    

    var books: [BookListItemModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("VIEW LOADED")

        booksCollectionView.dataSource = self
        booksCollectionView.delegate = self
        
        //let mainBookTableCell = UINib(nibName: BookDisplayTableCell.identifier, bundle: nil)
        
        navigationItem.backButtonTitle = "Books"
        //booksTableView.register(mainBookTableCell, forCellReuseIdentifier: BookDisplayTableCell.identifier)
        
        search("")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return 0
        print("count", books.count)
        return books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("GETTING CELL")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! BookListCollectionCellCollectionViewCell
        print("GOT CELL")
        let book = books[indexPath.row]
        cell.titleLabel.text = book.title // The row value is the same as the index of the desired text within the array.
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected")
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
                
                print("Book results loaded")
                
                DispatchQueue.main.sync {
                    self.booksCollectionView.reloadData()
                }
            } else {
                print("oops")
            }
            
        }

        task.resume()
    }

}
