import SwiftUI

struct BookDetails: View {
    @ObservedObject var book: BookViewModel
    
    var body: some View {
        VStack {
            HStack {
                BookCover(
                    preview: book.fullImagePreview,
                    image: book.fullImage,
                    metadata: book.fullImageMetadata
                )
            }
            Text(book.title).font(.title)
        }
        Text("Details!")
    }
}

private let cover = "https://my-library-cover-uploads.s3.amazonaws.com/medium-covers/573d1b97120426ef0078aa92/981f3e4f-2cc4-4c6c-be58-89764b709095.jpg"
private let coverPreview = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAAECAIAAADETxJQAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAM0lEQVR4nAEoANf/AP/41bWhkP/lzQD/69WQiIDr3sUAUVdddYKCO0dLAAkOHBcaJgECEuYIEjPlIgmqAAAAAElFTkSuQmCC"

private let bookPreview = Book(
    id: 1,
    title: "Title",
    authors: ["Author 1"],
    smallImage: cover,
    mediumImage: cover,
    smallImagePreview: ImageData(
        h: 76,
        w: 50,
        b64: coverPreview
    ),
    mediumImagePreview: ImageData(
        h: 161,
        w: 106,
        b64: coverPreview
    )
)

struct BookDetails_Previews: PreviewProvider {
    static var previews: some View {
        BookDetails(book: BookViewModel(bookPreview))
    }
}
