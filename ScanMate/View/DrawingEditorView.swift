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
                        Text("Please scan a photo first.")
                    } else {
                        if viewModel.currentPage < scanViewModel.scannedImages.count {
                            GeometryReader { geometry in
                                let image = viewModel.images[viewModel.currentPage]
                                    let imageSize = image.size
                                    let scale = min(geometry.size.width / imageSize.width,
                                                   geometry.size.height / imageSize.height)
                                    let scaledWidth = imageSize.width * scale
                                    let scaledHeight = imageSize.height * scale
                                ZStack {
                                    Image(uiImage: image)

                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                    
                                    CanvasView(
                                        drawing: Binding(
                                            get: { viewModel.canvasData[viewModel.currentPage] },
                                            set: { viewModel.canvasData[viewModel.currentPage] = $0 }
                                        ),
                                        tool: $viewModel.currentTool,
                                        canvasSize: CGSize(width: scaledWidth, height: scaledHeight)

                                    )
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    
                                }
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            }
                        } else {
                            Text("There was an issue retrieving the photo.")
                        }
                    }
                }
                
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
