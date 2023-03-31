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
    let mediumImage: String?
    let smallImagePreview: ImageData?
    let mediumImagePreview: ImageData?
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
    var smallImagePreview: UIImage?

    @Published
    var smallImageMetadata: ImageMetadata?

    @Published
    var smallImage: UIImage?

    @Published
    var fullImagePreview: UIImage?
    
    @Published
    var fullImageMetadata: ImageMetadata?
    
    @Published
    var fullImage: UIImage?
    
    @Published
    var title: String;
    
    @Published
    var authors: String
    
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
           // use the medium image if present since it *might* be higher resolution
           let imageUrl = book.mediumImage ?? book.smallImage,
           let downloadUrl = URL(string: imageUrl) {
            self.smallImageMetadata = ImageMetadata(width: preview.w, height: preview.h)
            self.smallImagePreview = getPreviewImage(preview: preview.b64)
            
            downloadCover(url: downloadUrl) { image in
                self.smallImage = image
                if (book.mediumImage == book.smallImage) {
                    self.fullImage = image
                }
            }
        }
        
        if let preview = book.mediumImagePreview,
           let imageUrl = book.mediumImage,
           let downloadUrl = URL(string: imageUrl) {
            self.fullImageMetadata = ImageMetadata(width: preview.w, height: preview.h)
            self.fullImagePreview = getPreviewImage(preview: preview.b64)
            
            if book.mediumImage != nil && book.mediumImage != book.smallImage {
                downloadCover(url: downloadUrl) { image in
                    self.fullImage = image
                }
            }
        }
    }
    
    private func getPreviewImage(preview: String) -> UIImage? {
        if let range = preview.range(of: "base64,"),
           let data = Data(base64Encoded: String(preview[range.upperBound...])),
           let uiImage = UIImage(data: data) {
            
            return uiImage
        } else {
            return nil
        }
    }
}

func downloadCover(url: URL, callback: @escaping (UIImage?) -> Void) {
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard error == nil else {
            print("Error downloading image", error)
            callback(nil)
            return
        }

        if let data = data {
            let result = UIImage(data: data)
            
            DispatchQueue.main.async {
                Task.init {
                    let delay = Double.random(in: 0.75...2.5)
                    try? await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
                    callback(result)
                }
            }
        }
    }.resume()
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
        NavigationStack {
            List($bookPacket.books) { book in
                NavigationLink(destination: {
                    BookDetails(book: book.wrappedValue)
                }, label: {
                    BooksDisplay(book: book.wrappedValue)
                })
            }
            .listStyle(.plain)
            .navigationTitle(Text("Books"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BookCover: View {
    let preview: UIImage?
    let image: UIImage?
    let metadata: ImageMetadata?
    
    var body: some View {
        if let realImage = image,
           let metadata = metadata {
            
            Image(uiImage: realImage)
                .resizable()
                .frame(
                    width: CGFloat(metadata.width),
                    height: CGFloat(metadata.height),
                    alignment: .leading
                )
        } else if
            let imageToRender = preview,
            let metadata = metadata {
            
            Image(uiImage: imageToRender)
                .resizable()
                .blur(radius: 5)
                .clipShape(Rectangle())
                .frame(
                    width: CGFloat(metadata.width),
                    height: CGFloat(metadata.height),
                    alignment: .leading
                )
        } else {
            Text("No image")
        }
    }
}

struct BooksDisplay: View {
    @ObservedObject var book: BookViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack{
                BookCover(
                    preview: book.smallImagePreview,
                    image: book.smallImage,
                    metadata: book.smallImageMetadata
                )
            }.frame(minWidth: 50, maxWidth: 50)
            VStack(alignment: .leading, spacing: 5) {
                Text(book.title)
                    .lineLimit(2)
                Text(book.authors)
                    .font(.subheadline.italic())
                    .padding(.leading, 5)
            }
        }.alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
    }
}


