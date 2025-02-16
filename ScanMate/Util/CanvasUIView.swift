//
//  CanvasUIView.swift
//  ScanMate
//
//  Created by 신얀 on 2/17/25.
//

import SwiftUI
import PencilKit
import UIKit

class CanvasUIView: PKCanvasView, PKCanvasViewDelegate {
    var drawingChanged: ((PKDrawing) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.backgroundColor = .clear
        self.isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        drawingChanged?(canvasView.drawing)  // ✅ 그릴 때마다 업데이트
    }
}
