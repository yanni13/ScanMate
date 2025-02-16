//
//  CanvasView.swift
//  ScanMate
//
//  Created by 신얀 on 2/16/25.
//

import SwiftUI
import PencilKit


// 드로잉 도구 타입
enum DrawingTool {
    case pen
    case marker
    case signature
}

struct Drawing {
    var lines: [Line] = []
}

struct Line {
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    var tool: DrawingTool
}


struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var tool: DrawingTool
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView
        
        init(_ parent: CanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            DispatchQueue.main.async {
                self.parent.drawing = canvasView.drawing
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = .clear
        updateTool(canvasView)
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
        updateTool(uiView)
    }
    
    private func updateTool(_ canvasView: PKCanvasView) {
        let newTool: PKTool
        switch tool {
        case .pen:
            newTool = PKInkingTool(.pen, color: .black, width: 3)
        case .marker:
            newTool = PKInkingTool(.marker, color: .yellow.withAlphaComponent(0.3), width: 10)
        case .signature:
            newTool = PKInkingTool(.pen, color: .blue, width: 2)
        }
        canvasView.tool = newTool
    }
}

