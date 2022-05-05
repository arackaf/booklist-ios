//
//  BookModel.swift
//  booklist-ios
//
//  Created by Adam Rackis on 5/5/22.
//

import Foundation

struct BookListItemModel {
    typealias BlurhashPreview = (width: Int, height: Int, blurhash: String)
    
    init(json: [String:Any]) {
        _id = json["_id"] as! String
        title = json["title"] as? String
        
        let smallImagePreview = json["smallImagePreview"];

        if smallImagePreview is BlurhashPreview {
            smallImagePreviewBlurhash = smallImagePreview as? BlurhashPreview
        }
        else if smallImagePreview is String {
            smallImagePreviewBase64 = smallImagePreview as? String
        }
    }
    
    var _id: String
    var title: String?
    var smallImagePreviewBase64: String?
    var smallImagePreviewBlurhash: BlurhashPreview?
}
