//
//  BookDisplayTableCell.swift
//  booklist-ios
//
//  Created by Adam Rackis on 5/5/22.
//

import UIKit

class BookDisplayTableCell: UITableViewCell {
    static let identifier = "BookDisplayTableCell"
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
//    @IBOutlet var titleLabel: UILabel!
//    @IBOutlet var junkLabel: UILabel!
//    @IBOutlet var coverContainer: UIStackView!
//    @IBOutlet var coverImageView: UIImageView!
    
    @IBOutlet var coverImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var coverContainer: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
