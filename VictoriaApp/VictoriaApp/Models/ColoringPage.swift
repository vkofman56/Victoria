//
//  ColoringPage.swift
//  Victoria
//
//  Data model representing a single coloring book page
//

import Foundation
import SwiftUI
import PDFKit

struct ColoringPage: Identifiable {
    let id: UUID
    let pageNumber: Int
    let pdfPage: PDFPage
    let thumbnail: UIImage
    let boundaryMask: UIImage?

    var isCompleted: Bool = false
    var completionPercentage: Double = 0.0
    var coloringBitmap: UIImage?

    init(pageNumber: Int, pdfPage: PDFPage, thumbnail: UIImage, boundaryMask: UIImage? = nil) {
        self.id = UUID()
        self.pageNumber = pageNumber
        self.pdfPage = pdfPage
        self.thumbnail = thumbnail
        self.boundaryMask = boundaryMask
    }
}

struct CompletionStatus {
    let isComplete: Bool
    let coverage: Double // 0.0 to 1.0
    let accuracy: Double // 0.0 to 1.0 (percentage within boundaries)
    let uniqueColors: Int
    let score: Int // 0-100

    static var incomplete: CompletionStatus {
        CompletionStatus(isComplete: false, coverage: 0, accuracy: 0, uniqueColors: 0, score: 0)
    }
}
