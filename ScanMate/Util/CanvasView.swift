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


struct CanvasView: UIViewRepresentable{
    @Binding var drawing: PKDrawing
    @Binding var tool: DrawingTool
    
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView
        let toolPicker = PKToolPicker()
        
        init(_ parent: CanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            DispatchQueue.main.async {
                self.parent.drawing = canvasView.drawing
            }
        }
        
        func setupToolPicker(for canvasView: PKCanvasView) {
                toolPicker.addObserver(canvasView)
                toolPicker.setVisible(true, forFirstResponder: canvasView)
                DispatchQueue.main.async {
                    canvasView.becomeFirstResponder()
                }
            }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.delegate = context.coordinator
        canvasView.drawing = drawing
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.isUserInteractionEnabled = true
        context.coordinator.setupToolPicker(for: canvasView)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            print("Updating canvasView.drawing: \(drawing.strokes.count) strokes")
            uiView.drawing = drawing
        }
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

