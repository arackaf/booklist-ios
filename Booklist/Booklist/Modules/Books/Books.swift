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

struct Book : Codable, Identifiable {
    let id: Int
    let title: String
    let pages: Int
    let authors: [String]
    let smallImage: String?
    let smallImagePreview: ImageData?
}

struct BookResults: Codable {
    let books: [Book]
    let totalBooks: Int
    let page: Int
    let totalPages: Int
}

struct Books: View {
    @State private var bookResults: BookResults?
    
    var body: some View {
        VStack{
            if bookResults == nil {
                Text("Loading ...")
            } else {
                List(bookResults!.books) { book in
                    HStack(alignment: .top, spacing: 10) {
                        VStack{
                            if let smallImage = book.smallImage,
                               let smallImageInfo = book.smallImagePreview {
                                
                                AsyncImage(
                                    url: URL(string: smallImage),
                                    content: { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(
                                                maxWidth: 50,
                                                alignment: .leading
                                            )
                                    },
                                    placeholder: {
                                        Text("...")
                                    }
                                )
                            } else {
                                Text("No image")
                            }
                        }.frame(minWidth: 50, maxWidth: 50)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(book.title)
                            Text(book.authors.joined(separator: ", "))
                                .font(.subheadline.italic())
                                .padding(.leading, 5)
                        }
                    }
                }
            }
        }.task(priority: .background) {
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
                        self.bookResults = try decoder.decode(BookResults.self, from: data)
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
