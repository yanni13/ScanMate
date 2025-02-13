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
    
    var body: some View {
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
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(0..<viewModel.scannedImages.count, id: \.self) { index in
//                            Image(uiImage: scannedImages[index])
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: 200)
//                                .cornerRadius(8)
//                                .shadow(radius: 2)
                            
                            ImageSelectionView(image: viewModel.scannedImages[index], isSelected: viewModel.selectedImages.contains(index))
                                .onTapGesture {
                                    if viewModel.selectedImages.contains(index) {
                                        viewModel.selectedImages.remove(index)
                                    } else {
                                        viewModel.selectedImages.insert(index)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            Spacer()
            
            VStack {
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
                    viewModel.showingExportOptions = true
                }, label: {
                    HStack(spacing: 13) {
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
            .edgesIgnoringSafeArea(.all)


        }
        .edgesIgnoringSafeArea(.all)
        .padding(20)
        .fullScreenCover(isPresented: $viewModel.isShowingScanner) {
                        DocumentScannerView { scannedImages in
                            self.viewModel.scannedImages = scannedImages
                        }
                    }
        .sheet(isPresented: $viewModel.showingExportOptions) {
                    if let pdf = viewModel.createPDF() {
                        ShareSheet(items: [pdf])
                    }
                }

    }
    
}
