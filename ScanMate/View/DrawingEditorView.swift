//
//  DrawingEditorView.swift
//  ScanMate
//
//  Created by 신얀 on 2/16/25.
//

import SwiftUI
import UIKit
import PencilKit

// 드로잉 편집 뷰
struct DrawingEditorView: View {
    @StateObject private var viewModel: DrawingEditorViewModel
    @EnvironmentObject var scanViewModel: ScanViewModel
    @Environment(\.presentationMode) var presentationMode
    var onEditingComplete: ([UIImage]) -> Void
    
    init(images: [UIImage], onEditingComplete: @escaping ([UIImage]) -> Void) {
        _viewModel = StateObject(wrappedValue: DrawingEditorViewModel(images: images))
        self.onEditingComplete = onEditingComplete
        viewModel.updateImages(newImages: images) // images 배열을 초기화
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if scanViewModel.scannedImages.isEmpty {
                        Text("사진을 불러오지 못했습니다.-사진이 비어서")
                    } else {
                        if viewModel.currentPage < scanViewModel.scannedImages.count {
                            Image(uiImage: scanViewModel.scannedImages[viewModel.currentPage])
                                .resizable()
                                .scaledToFit()

                            CanvasView(
                                drawing: Binding(
                                    get: {
                                        // currentPage가 canvasData의 범위 내에 있는지 체크
                                        guard viewModel.currentPage < viewModel.canvasData.count else {
                                            print("Invalid currentPage: \(viewModel.currentPage)")
                                            return PKDrawing() // 기본 PKDrawing 반환
                                        }
                                        return viewModel.canvasData[viewModel.currentPage]
                                    },
                                    set: { viewModel.updateDrawing(drawing: $0, at: viewModel.currentPage) }
                                ),
                                tool: $viewModel.currentTool
                            )

                        } else {
                            Text("사진을 불러오지 못했습니다.-인덱스 잘못 참조된듯")
                        }
                    }
                }
                
                // 도구 선택 버튼
                HStack(spacing: 20) {
                    Button(action: { viewModel.currentTool = .pen }) {
                        Image(systemName: "pencil")
                            .foregroundColor(viewModel.currentTool == .pen ? .blue : .gray)
                    }
                    
                    Button(action: { viewModel.currentTool = .marker }) {
                        Image(systemName: "highlighter")
                            .foregroundColor(viewModel.currentTool == .marker ? .blue : .gray)
                    }
                    
                    Button(action: { viewModel.currentTool = .signature }) {
                        Image(systemName: "signature")
                            .foregroundColor(viewModel.currentTool == .signature ? .blue : .gray)
                    }
                }
                .padding()
                
                // 페이지 이동 버튼
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
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("완료") {
                    let editedImages = (0..<viewModel.images.count).compactMap { viewModel.getMergedImage(at: $0) }
                    onEditingComplete(editedImages)
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .navigationBarTitle("서명/드로잉", displayMode: .inline)
        }
    }
}



