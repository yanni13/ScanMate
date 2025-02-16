//
//  ScanView.swift
//  ScanMate
//
//  Created by 신얀 on 2/13/25.
//

import SwiftUI
import AVFoundation
import Photos

struct ScanView: View {
    @StateObject private var viewModel = ScanViewModel()
    @StateObject private var drawingEditorViewModel: DrawingEditorViewModel

    @State private var showPopUpView = false
    @State private var showDrawingEditor = false // 드로잉 에디터 표시 여부
    @State private var selectedImagesForDrawing: [UIImage] = [] // 드로잉할 이미지들
    
    init() {
        _drawingEditorViewModel = StateObject(wrappedValue: DrawingEditorViewModel(images: [])) // 초기화할 때 빈 배열로 시작
    }
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.scannedImages.isEmpty {
                    VStack(spacing: 0) {
                        Image(systemName: "document.viewfinder")
                            .font(.system(size: 70, weight: .regular, design: .default))
                            .foregroundStyle(.gray)
                    }
                    
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.94, green: 0.95, blue: 0.96))
                    
                    .cornerRadius(10)
                } else {
                    ScrollView {
                        Spacer().frame(height: 20)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(0..<viewModel.scannedImages.count, id: \.self) { index in
                                
                                ImageSelectionView(image: viewModel.scannedImages[index], isSelected: viewModel.selectedImages.contains(index))
                                    .onTapGesture {
                                        if viewModel.selectedImages.contains(index) {
                                            viewModel.selectedImages.remove(index)
                                        } else {
                                            viewModel.selectedImages.insert(index)
                                        }
                                        print("Selected Images: \(viewModel.selectedImages)")

                                    }
                                    .onLongPressGesture {
                                        selectedImagesForDrawing = [viewModel.scannedImages[index]]
                                        showDrawingEditor = true
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
                
                VStack {
                    HStack {
                        Button(action: {
                            viewModel.isShowingScanner = true
                            viewModel.checkCameraPermission()
                        }, label: {
                            HStack(spacing: 13) {
                                Image(systemName: "camera.viewfinder")
                                
                                Text("Scan Image")
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(.primary)
                            .cornerRadius(10)
                            .buttonStyle(.plain)
                        })
                        
                        
                        Button(action: {
                            viewModel.showingFormatSelection = true
                        }, label: {
                            HStack(spacing: 10) {
                                Image(systemName: "folder.fill")
                                
                                Text("Convert to File")
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color(red: 0.87, green: 0.88, blue: 0.9))
                            .cornerRadius(10)
                            .buttonStyle(.plain)
                        })
                    }
                    
                    HStack {
                        // 선택된 이미지들에 대해 드로잉 편집 버튼 추가
                        //if !viewModel.selectedImages.isEmpty {
                        
                        Button(action: {
                            
                        }, label: {
                            HStack(spacing: 13) {
                                Image(systemName: "trash")
                                Text("Reset")
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color(red: 0.94, green: 0.95, blue: 0.96))
                            .cornerRadius(10)
                            .buttonStyle(.plain)
                        })
                        
                        
                        Button(action: {
                            selectedImagesForDrawing = viewModel.selectedImages.sorted()
                                .compactMap { index in
                                    guard index < viewModel.scannedImages.count else { return nil }
                                    return viewModel.scannedImages[index]
                                }
                            print("Selected images for drawing: \(selectedImagesForDrawing.count)")
                            drawingEditorViewModel.images = selectedImagesForDrawing


                            showDrawingEditor = true
                        }, label: {
                                HStack(spacing: 13) {
                                    Image(systemName: "pencil.and.scribble")
                                        
                                    Text("Edit")
                                }
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color(red: 0.94, green: 0.95, blue: 0.96))
                                .cornerRadius(10)
                                .buttonStyle(.plain)
                            })
                        //}
                    }
                    
 

                    
                }
                .actionSheet(isPresented: $viewModel.showingFormatSelection) {
                    ActionSheet(
                        title: Text("Select File Format"),
                        buttons: [
                            .default(Text("PDF")) {
                                viewModel.selectedExportFormat = .pdf
                                viewModel.showingExportOptions = true
                            },
                            .default(Text("JPEG")) {
                                viewModel.selectedExportFormat = .jpeg
                                viewModel.showingExportOptions = true
                            },
                            .cancel()
                        ]
                    )
                }
                .fullScreenCover(isPresented: $viewModel.isShowingScanner) {
                    DocumentScannerView { scannedImages in
                        self.viewModel.scannedImages = scannedImages
                    }
                }
                .sheet(isPresented: $viewModel.showingExportOptions) {
                    if let exportUrl = viewModel.exportFile() {
                        ShareSheet(items: [exportUrl])
                    }
                }
                .fullScreenCover(isPresented: $showDrawingEditor) {
                    DrawingEditorView(images: selectedImagesForDrawing) { editedImages in
                        // 편집된 이미지로 원본 이미지 업데이트
                        for (index, editedImage) in editedImages.enumerated() {
                            if let originalIndex = viewModel.selectedImages.sorted()[safe: index] {
                                viewModel.scannedImages[originalIndex] = editedImage
                            }
                        }
                    }
                    .environmentObject(viewModel)
                }
                
            }
            .edgesIgnoringSafeArea(.all)
            .padding(20)

        }
        .onAppear {
            print("Selected Images: \(viewModel.selectedImages)")
        }
    }
    
}


