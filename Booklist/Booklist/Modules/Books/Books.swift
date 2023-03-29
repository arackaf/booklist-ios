//
//  Books.swift
//  Booklist
//
//  Created by Adam Rackis on 3/28/23.
//

import SwiftUI

struct ImageMetadata {
    let width: Int
    let height: Int
    let preview: String
}

struct ImageData : Codable {
    let h: Int
    let w: Int
    let b64: String
}

struct Book : Codable, Identifiable {
    let id: Int
    let title: String
    let pages: Int
    let authors: [String]?
    let smallImage: String?
    let smallImagePreview: ImageData?
}

struct BookResults: Codable {
    let books: [Book]
    let totalBooks: Int
    let page: Int
    let totalPages: Int
}

class BookViewModel: ObservableObject, Identifiable {
    var id: Int {
        self.book.id
    }
    
    @Published
    var imageToRender: UIImage?
    
    @Published
    var title: String;
    
    @Published
    var authors: String
    
    @Published
    var imageUrl: String?
    
    @Published
    var imageMetadata: ImageMetadata?
    
    private let book: Book
    init(_ book: Book) {
        self.book = book
        self.title = book.title
        self.imageUrl = book.smallImage
        if let preview = book.smallImagePreview {
            self.imageMetadata = ImageMetadata(width: preview.w, height: preview.h, preview: preview.b64)
            
            print("PRE", preview.b64)

        
            if let range = preview.b64.range(of: "base64,"),
               let data = Data(base64Encoded: String(preview.b64[range.upperBound...])),
               let uiImage = UIImage(data: data) {
                
                print("YES")
                self.imageToRender = uiImage
            }
        }
        
        if let authorsArr = book.authors, !authorsArr.isEmpty {
            self.authors = authorsArr.joined(separator: ", ")
        } else {
            self.authors = ""
        }
        
        
    }
}

class BookPacket: ObservableObject {
    @Published
    var books: [BookViewModel]
    
    init(books: [BookViewModel]) {
        self.books = books
    }
}

struct Books: View {
    @StateObject private var bookPacket: BookPacket = BookPacket(books: [])
    
    var body: some View {
        VStack{
            if bookPacket.books.isEmpty {
                Text("Loading ...")
            } else {
                BooksList(bookPacket: bookPacket)
            }
        }.task(priority: .userInitiated) {
            let url = URL(string: "https://mylibrary.io/api/books-public")!
            var request = URLRequest(url: url)
            
            // the request is JSON
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // the response expected to be in JSON format
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    print("Error loading books:", String(describing: error?.localizedDescription))
                    return
                }
                
                if let data {
                    let decoder = JSONDecoder()
                    do {
                        let results = try decoder.decode(BookResults.self, from: data)
                        
                        DispatchQueue.main.async {
                            self.bookPacket.books = results.books.map { BookViewModel($0) }
                        }
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

struct BooksList: View {
    @ObservedObject var bookPacket: BookPacket
    
    var body: some View {
        List($bookPacket.books) { book in
            
            HStack(alignment: .top, spacing: 10) {
                VStack{
                    if let imageToRender = book.wrappedValue.imageToRender,
                       let metadata = book.wrappedValue.imageMetadata {
                        
                        Image(uiImage: imageToRender)
                            .resizable()
                            .blur(radius: 5)
                            .clipShape(Rectangle())
                            .frame(
                                minWidth: CGFloat(metadata.width),
                                maxWidth: CGFloat(metadata.width),
                                minHeight: CGFloat(metadata.height),
                                maxHeight: CGFloat(metadata.height),
                                alignment: .leading
                            )
                        
                        
//                        AsyncImage(
//                            url: URL(string: imageUrl),
//                            content: { image in
//                                image.resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(
//                                        minWidth: CGFloat(metadata.width),
//                                        maxWidth: CGFloat(metadata.width),
//                                        alignment: .leading
//                                    )
//                            },
//                            placeholder: {
//                                Text("...")
//                            }
//                        )
                    } else {
                        Text("No image")
                    }
                }.frame(minWidth: 50, maxWidth: 50)
                VStack(alignment: .leading, spacing: 5) {
                    Text(book.title.wrappedValue)
                    Text("authors")
                        .font(.subheadline.italic())
                        .padding(.leading, 5)
                }
            }
        }
    }
}
