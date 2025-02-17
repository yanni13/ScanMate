// DrawingEditorView.swift

import SwiftUI
import UIKit
import PencilKit

struct DrawingEditorView: View {
    @StateObject private var viewModel: DrawingEditorViewModel
    @EnvironmentObject var scanViewModel: ScanViewModel
    @Environment(\.presentationMode) var presentationMode
    var onEditingComplete: ([UIImage]) -> Void
    
    init(images: [UIImage], onEditingComplete: @escaping ([UIImage]) -> Void) {
        _viewModel = StateObject(wrappedValue: DrawingEditorViewModel(images: images))
        self.onEditingComplete = onEditingComplete
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if scanViewModel.scannedImages.isEmpty {
                        Text("사진을 불러오지 못했습니다.")
                    } else {
                        if viewModel.currentPage < scanViewModel.scannedImages.count {
                            GeometryReader { geometry in
                                ZStack {
//                                    Image(uiImage: scanViewModel.scannedImages[viewModel.currentPage])
                                    Image(uiImage: viewModel.images[viewModel.currentPage])

                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                    
                                    CanvasView(
                                        drawing: Binding(
                                            get: { viewModel.canvasData[viewModel.currentPage] },
                                            set: { viewModel.canvasData[viewModel.currentPage] = $0 }
                                        ),
                                        tool: $viewModel.currentTool
                                    )
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    
                                }
                            }
                        } else {
                            Text("인덱스가 범위를 벗어났습니다.")
                        }
                    }
                }
//                
//                HStack(spacing: 20) {
//                    Button(action: { viewModel.currentTool = .pen }) {
//                        Image(systemName: "pencil")
//                            .foregroundColor(viewModel.currentTool == .pen ? .blue : .gray)
//                    }
//                    
//                    Button(action: { viewModel.currentTool = .marker }) {
//                        Image(systemName: "highlighter")
//                            .foregroundColor(viewModel.currentTool == .marker ? .blue : .gray)
//                    }
//                    
//                    Button(action: { viewModel.currentTool = .signature }) {
//                        Image(systemName: "signature")
//                            .foregroundColor(viewModel.currentTool == .signature ? .blue : .gray)
//                    }
//                }
//                .padding()
                
                if viewModel.images.count > 1 {
                    HStack {
                        Button(action: {
                            if viewModel.currentPage > 0 {
                                viewModel.currentPage -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(viewModel.currentPage == 0)
                        
                        Text("\(viewModel.currentPage + 1) / \(viewModel.images.count)")
                            .padding(.horizontal)
                        
                        Button(action: {
                            if viewModel.currentPage < viewModel.images.count - 1 {
                                viewModel.currentPage += 1
                            }
                        }) {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(viewModel.currentPage == viewModel.images.count - 1)
                    }
                    .padding()
                }
            }
            .navigationBarItems(
                leading: Button("cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("complete") {
                    let editedImages = (0..<viewModel.images.count).compactMap { viewModel.getMergedImage(at: $0) }
                    onEditingComplete(editedImages)
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .navigationBarTitle("Edit", displayMode: .inline)
        }
    }
}
