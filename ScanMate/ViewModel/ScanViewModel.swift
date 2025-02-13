//
//  ScanViewModel.swift
//  ScanMate
//
//  Created by 신얀 on 2/13/25.
//

import SwiftUI
import AVFoundation
import PDFKit

class ScanViewModel: ObservableObject {
    @Published var scannedImages: [UIImage] = []
    @Published var selectedImages: Set<Int> = []
    @Published var isShowingScanner = false
    @Published var showingExportOptions = false
    @Published var sourceType: UIImagePickerController.SourceType = .camera
    
    func addScannedImages(_ images: [UIImage]) {
        scannedImages.append(contentsOf: images)
    }
    
    func createPDF() -> Data? {
        let pdfDocument = PDFDocument()
        
        let sortedIndices = selectedImages.sorted()
        for index in sortedIndices {
            if let image = scannedImages[safe: index] {
                guard let page = PDFPage(image: image) else { continue }
                pdfDocument.insert(page, at: pdfDocument.pageCount)
            }
        }
        
        return pdfDocument.dataRepresentation()
    }
    
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            sourceType = .camera
        case .denied, .restricted:
            showAlertAuth(type: "카메라")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.sourceType = .camera
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
        
        UIApplication.shared.windows.first?.rootViewController?.present(alertVC, animated: true)
    }
}
