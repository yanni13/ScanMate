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
    @State private var scannedImages: [UIImage] = []
    @State private var isShowingScanner = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera

    
    
    var body: some View {
        VStack {
            
            if scannedImages.isEmpty {
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
                        ForEach(0..<scannedImages.count, id: \.self) { index in
                            Image(uiImage: scannedImages[index])
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            Spacer()
            
            VStack {
                Button(action: {
                    isShowingScanner = true
                    checkCameraPermission()
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
                    
                }, label: {
                    HStack(spacing: 13) {
                        Image(systemName: "camera.viewfinder")
                        
                        Text("Scan Image")
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
        .padding(20)

        .fullScreenCover(isPresented: $isShowingScanner) {
                        DocumentScannerView { scannedImages in
                            self.scannedImages = scannedImages
                        }
                    }
        

    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            sourceType = .camera
        case .denied, .restricted:
            showAlertAuth(type: "카메라")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.sourceType = .camera
                    }
                }
            }
        @unknown default:
            break
        }
    }
    
    private func showAlertAuth(type: String) {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "이 앱"
        let alertVC = UIAlertController(
            title: "설정",
            message: "\(appName)이(가) \(type) 접근 허용되어 있지 않습니다. 설정화면으로 가시겠습니까?",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(confirmAction)
        UIApplication.shared.windows.first!.rootViewController!.present(alertVC, animated: true, completion: nil)
    }
    
}
