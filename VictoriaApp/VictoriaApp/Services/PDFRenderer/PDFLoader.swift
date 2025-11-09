//
//  PDFLoader.swift
//  Victoria
//
//  Handles loading and rendering PDF coloring book pages
//

import Foundation
import PDFKit
import UIKit

class PDFLoader {
    static let shared = PDFLoader()

    private var document: PDFDocument?
    private var renderedPages: [Int: UIImage] = [:]

    private init() {}

    /// Load PDF from app bundle
    func loadPDF(named fileName: String) -> Bool {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "pdf") else {
            print("PDF file not found: \(fileName).pdf")
            return false
        }

        guard let pdfDocument = PDFDocument(url: url) else {
            print("Failed to load PDF from: \(url)")
            return false
        }

        self.document = pdfDocument
        print("Successfully loaded PDF with \(pdfDocument.pageCount) pages")
        return true
    }

    /// Get total number of pages
    var pageCount: Int {
        return document?.pageCount ?? 0
    }

    /// Get a specific PDF page
    func getPage(at index: Int) -> PDFPage? {
        return document?.page(at: index)
    }

    /// Render a PDF page to UIImage at specified size
    func renderPage(at index: Int, size: CGSize) -> UIImage? {
        // Check cache first
        if let cached = renderedPages[index] {
            return cached
        }

        guard let page = document?.page(at: index) else {
            return nil
        }

        let image = renderPage(page, size: size)
        renderedPages[index] = image
        return image
    }

    /// Render a PDFPage to UIImage
    func renderPage(_ page: PDFPage, size: CGSize) -> UIImage {
        let pageRect = page.bounds(for: .mediaBox)
        let scale = min(size.width / pageRect.width, size.height / pageRect.height)
        let scaledSize = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)

        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        let image = renderer.image { context in
            UIColor.white.set()
            context.fill(CGRect(origin: .zero, size: scaledSize))

            context.cgContext.translateBy(x: 0, y: scaledSize.height)
            context.cgContext.scaleBy(x: scale, y: -scale)

            page.draw(with: .mediaBox, to: context.cgContext)
        }

        return image
    }

    /// Generate thumbnail for page
    func getThumbnail(at index: Int, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        return renderPage(at: index, size: size)
    }

    /// Get all pages as ColoringPage models
    func getAllPages() -> [ColoringPage] {
        guard let doc = document else { return [] }

        return (0..<doc.pageCount).compactMap { index in
            guard let pdfPage = doc.page(at: index),
                  let thumbnail = getThumbnail(at: index) else {
                return nil
            }

            return ColoringPage(
                pageNumber: index + 1,
                pdfPage: pdfPage,
                thumbnail: thumbnail
            )
        }
    }

    /// Clear cache to free memory
    func clearCache() {
        renderedPages.removeAll()
    }
}
