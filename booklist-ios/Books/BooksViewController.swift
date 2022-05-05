//
//  BooksViewController.swift
//  booklist-ios
//
//  Created by Adam Rackis on 5/4/22.
//

import UIKit

//class BookTableCell: UITableViewCell {
//
//    @IBOutlet var cellLabel: UILabel!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//}

class BooksViewController: UIViewController, UITableViewDataSource {
    @IBOutlet var booksTableView: UITableView!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var dumbButton: UIButton!
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookDisplayTableCell.identifier, for: indexPath) as! BookDisplayTableCell
        cell.titleLabel.text = "Ayyyyy yo!"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.booksTableView.dataSource = self
        
        let mainBookTableCell = UINib(nibName: BookDisplayTableCell.identifier, bundle: nil)
        self.booksTableView.register(mainBookTableCell, forCellReuseIdentifier: BookDisplayTableCell.identifier)
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
