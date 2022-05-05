//
//  BooksViewController.swift
//  booklist-ios
//
//  Created by Adam Rackis on 5/4/22.
//

import UIKit

class BookTableCell: UITableViewCell {

    @IBOutlet var cellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class BooksViewController: UIViewController, UITableViewDataSource {


    @IBOutlet var booksTableView: UITableView!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var dumbButton: UIButton!
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookTableCell", for: indexPath) as! BookTableCell
        
        
        cell.textLabel?.text = "Foo " + indexPath.description
        cell.cellLabel.text = "Ayyyyy"
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.booksTableView.dataSource = self
    }
    
    @IBAction func onDumbClick(_ sender: Any) {
        self.topLabel.text = "Ayoooooo"
    }
    

}
