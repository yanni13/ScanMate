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
//        let drawingImage = canvasData[index].image(from: CGRect(origin: .zero, size: baseImage.size), scale: 1.0)
//
//        UIGraphicsBeginImageContextWithOptions(baseImage.size, false, 0)
//        baseImage.draw(in: CGRect(origin: .zero, size: baseImage.size))
//        drawingImage.draw(in: CGRect(origin: .zero, size: baseImage.size))
//        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return mergedImage
//    }
    
    func getMergedImage(at index: Int) -> UIImage? {
        guard index < images.count && index < canvasData.count else {
            print("Error: Invalid index (\(index)) for getMergedImage")
            return nil
        }
        
        let baseImage = images[index]
        let drawing = canvasData[index]
        
        UIGraphicsBeginImageContextWithOptions(baseImage.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Error: Failed to create graphics context")
            return nil
        }
        
        // 베이스 이미지 그리기
        baseImage.draw(in: CGRect(origin: .zero, size: baseImage.size))
        
        // 드로잉을 이미지로 변환하고 그리기
        let drawingRect = CGRect(origin: .zero, size: baseImage.size)
        let drawingImage = drawing.image(from: drawingRect, scale: UIScreen.main.scale)
        drawingImage.draw(in: CGRect(origin: .zero, size: baseImage.size))
        
        guard let mergedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            print("Error: Failed to get merged image from context")
            return nil
        }
        
        return mergedImage
    }


}
