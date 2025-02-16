//
//  DrawingEditorViewModel.swift
//  ScanMate
//
//  Created by 신얀 on 2/16/25.
//

import SwiftUI
import PencilKit
import UIKit

class DrawingEditorViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    @Published var currentPage: Int = 0
    @Published var currentTool: DrawingTool = .pen
    @Published var canvasData: [PKDrawing]

    
    init(images: [UIImage]) {
        self.images = images
        print("images count: \(images.count)")  // 이미지를 제대로 받는지 확인
        
        // canvasData 배열의 크기를 images 배열 크기와 동일하게 초기화
        self.canvasData = Array(repeating: PKDrawing(), count: images.count)
    }
    
    
    func updateImages(newImages: [UIImage]) {
        self.images = newImages
        self.canvasData = Array(repeating: PKDrawing(), count: newImages.count)
        print("Updated images count: \(newImages.count)")
    }
    
    func updateDrawing(drawing: PKDrawing, at index: Int) {
        guard index < canvasData.count else {
            print("Error: Invalid index for updateDrawing")
            return
        }
        canvasData[index] = drawing
        objectWillChange.send()  // 명시적으로 변경 알림
    }
    
//    func getMergedImage(at index: Int) -> UIImage? {
//        guard index < images.count else { return nil }
//        
//        let baseImage = images[index]
//        let drawing = canvasData[index]
//
//        let renderer = UIGraphicsImageRenderer(size: baseImage.size)
//        return renderer.image { context in
//            baseImage.draw(in: CGRect(origin: .zero, size: baseImage.size))
//            drawing.image(from: CGRect(origin: .zero, size: baseImage.size), scale: 1.0)
//                .draw(in: CGRect(origin: .zero, size: baseImage.size))
//        }
//    }
    func getMergedImage(at index: Int) -> UIImage? {
        guard index < images.count else { return nil }

        let baseImage = images[index]
        let drawingImage = canvasData[index].image(from: CGRect(origin: .zero, size: baseImage.size), scale: 1.0)

        UIGraphicsBeginImageContextWithOptions(baseImage.size, false, 0)
        baseImage.draw(in: CGRect(origin: .zero, size: baseImage.size))
        drawingImage.draw(in: CGRect(origin: .zero, size: baseImage.size))
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return mergedImage
    }

}
