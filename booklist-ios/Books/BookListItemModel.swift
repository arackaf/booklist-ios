//
//  BookModel.swift
//  booklist-ios
//
//  Created by Adam Rackis on 5/5/22.
//

import Foundation

struct BookListItemModel {
    typealias BlurhashPreview = (width: Int, height: Int, blurhash: String)
    
    init(_ json: [String:Any]) {
        _id = json["_id"] as! String
        title = json["title"] as? String
        
        let mobileImagePreview = json["mobileImagePreview"];
        
        if mobileImagePreview is BlurhashPreview {
            mobileImagePreviewBlurhash = mobileImagePreview as? BlurhashPreview
        }
        else if mobileImagePreview is String {
            mobileImagePreviewBase64 = mobileImagePreview as? String
        }
    }
    
    var _id: String
    var title: String?
    var mobileImagePreviewBase64: String?
    var mobileImagePreviewBlurhash: BlurhashPreview?
}

