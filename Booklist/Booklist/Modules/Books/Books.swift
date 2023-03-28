//
//  Books.swift
//  Booklist
//
//  Created by Adam Rackis on 3/28/23.
//

import SwiftUI

struct ImageData : Codable {
    let h: Int
    let w: Int
    let b64: String
}

struct Book : Codable {
    let id: Int
    let title: String
    let pages: Int
    let authors: [String]
    let smallImage: String
    let smallImagePreview: ImageData
}

struct BookResults: Codable {
    let books: [Book]
    let totalBooks: Int
    let page: Int
    let totalPages: Int
}

struct Books: View {
    var body: some View {
        Text("Books").task(priority: .background) {
            print("a")
            let url = URL(string: "https://mylibrary.io/api/books-public")!
            var request = URLRequest(url: url)
            
            // the request is JSON
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // the response expected to be in JSON format
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                print("Callback")
                guard error == nil else {
                    print("error")
                    print(String(describing: error?.localizedDescription))
                    return
                }
                
                if let data {
                    let decoder = JSONDecoder()
                    do {
                        let j = try decoder.decode(BookResults.self, from: data)
                        print(j)
                    } catch {
                        print("Error decoding:", error)
                    }
                }
                
            }.resume()
        }
    }
}

struct Books_Previews: PreviewProvider {
    static var previews: some View {
        Books()
    }
}
