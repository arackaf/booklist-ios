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
    var imagePreview: UIImage?
    
    @Published
    var imageReady: UIImage?
    
    @Published
    var title: String;
    
    @Published
    var authors: String
    
    @Published
    var imageMetadata: ImageMetadata?
    
    private let book: Book
    init(_ book: Book) {
        self.book = book
        self.title = book.title
        
        if let authorsArr = book.authors, !authorsArr.isEmpty {
            self.authors = authorsArr.joined(separator: ", ")
        } else {
            self.authors = ""
        }
        
        if let preview = book.smallImagePreview,
           let imageUrl = book.smallImage,
           let downloadUrl = URL(string: imageUrl) {
            self.imageMetadata = ImageMetadata(width: preview.w, height: preview.h, preview: preview.b64)

            if let range = preview.b64.range(of: "base64,"),
               let data = Data(base64Encoded: String(preview.b64[range.upperBound...])),
               let uiImage = UIImage(data: data) {
                
                self.imagePreview = uiImage
            }
            
            print("downloading")
            URLSession.shared.dataTask(with: downloadUrl) { (data, response, error) in
                guard error == nil else {
                    print("Error downloading image", error)
                    return
                }

                if let data = data {
                    print("GOT REAL IMAGE")

                    DispatchQueue.main.async { [weak self] in
                        Task.init {
                            let delay = Double.random(in: 0.75...2.5)
                            try? await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
                            self?.imageReady = UIImage(data: data)
                        }
                    }
                }
            }.resume()
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
        }.onAppear() {
            self.bookPacket.books = []
        }
        .task(priority: .userInitiated) {
            self.bookPacket.books = []
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
            BooksDisplay(book: book.wrappedValue)
        }
    }
}

struct BooksDisplay: View {
    @ObservedObject var book: BookViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack{
                if let realImage = book.imageReady,
                   let metadata = book.imageMetadata {
                    
                    Image(uiImage: realImage)
                        .resizable()
                        .frame(
                            minWidth: CGFloat(metadata.width),
                            maxWidth: CGFloat(metadata.width),
                            minHeight: CGFloat(metadata.height),
                            maxHeight: CGFloat(metadata.height),
                            alignment: .leading
                        )
                } else if
                    let imageToRender = book.imagePreview,
                    let metadata = book.imageMetadata {
                    
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
                } else {
                    Text("No image")
                }
            }.frame(minWidth: 50, maxWidth: 50)
            VStack(alignment: .leading, spacing: 5) {
                Text(book.title)
                Text(book.authors)
                    .font(.subheadline.italic())
                    .padding(.leading, 5)
            }
        }
    }
}
