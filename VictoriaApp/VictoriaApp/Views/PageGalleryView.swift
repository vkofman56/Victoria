//
//  PageGalleryView.swift
//  Victoria
//
//  Gallery view showing all coloring book pages
//

import SwiftUI

struct PageGalleryView: View {
    @StateObject private var viewModel = PageGalleryViewModel()
    @State private var selectedPage: ColoringPage?

    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 20)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.pages.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No Coloring Pages Found")
                            .font(.title2)
                            .foregroundColor(.gray)

                        Text("Add your PDF coloring book to Assets/")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.pages) { page in
                            PageThumbnailCard(page: page)
                                .onTapGesture {
                                    selectedPage = page
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Victoria Coloring Book")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        AudioManager.shared.toggleMute()
                    }) {
                        Image(systemName: AudioManager.shared.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    }
                }
            }
            .sheet(item: $selectedPage) { page in
                ColoringView(page: page)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct PageThumbnailCard: View {
    let page: ColoringPage

    var body: some View {
        VStack(spacing: 8) {
            Image(uiImage: page.thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
                .cornerRadius(12)
                .shadow(radius: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            Text("Page \(page.pageNumber)")
                .font(.headline)

            if page.isCompleted {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

class PageGalleryViewModel: ObservableObject {
    @Published var pages: [ColoringPage] = []

    init() {
        loadPages()
    }

    func loadPages() {
        // Try to load PDF from Assets
        // In a real app, the PDF would be in the bundle
        if PDFLoader.shared.loadPDF(named: "coloring-book") {
            pages = PDFLoader.shared.getAllPages()
            print("Loaded \(pages.count) pages")
        } else {
            print("No PDF found. Add coloring-book.pdf to Assets/")
            pages = []
        }
    }

    func refreshPages() {
        loadPages()
    }
}

struct PageGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        PageGalleryView()
    }
}
