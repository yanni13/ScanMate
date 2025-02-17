//
//  ScanViewModel.swift
//  ScanMate
//
//  Created by 신얀 on 2/13/25.
//

import SwiftUI
import AVFoundation
import PDFKit

// MARK: 변환하고 싶은 파일 확장자 - ExportFormat
enum ExportFormat {
    case pdf
    case jpeg
}


// MARK: ScanViewModel
class ScanViewModel: ObservableObject {
    @Published var scannedImages: [UIImage] = []
    @Published var selectedImages: Set<Int> = []
    @Published var isShowingScanner = false
    @Published var showingExportOptions = false
    @Published var sourceType: UIImagePickerController.SourceType = .camera
    @Published var selectedExportFormat: ExportFormat? = nil
    @Published var showingFormatSelection = false
    @Published var mergedImage: UIImage?

    
    func addScannedImages(_ images: [UIImage]) {
        scannedImages.append(contentsOf: images)
    }
    
    func updateScannedImages(with mergedImage: UIImage, at indices: [Int]) {
            guard !indices.isEmpty else { return }
            
            // 첫 번째 선택된 이미지 위치에 병합된 이미지 삽입
            let firstIndex = indices.first!
            scannedImages[firstIndex] = mergedImage

            // 나머지 선택된 이미지 제거
            for index in indices.dropFirst().reversed() {
                scannedImages.remove(at: index)
            }

            // 선택 목록 초기화
            selectedImages.removeAll()
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

    func createJPEG() -> Data? {
        let selectedIndices = selectedImages.sorted()
        guard !selectedIndices.isEmpty,
              let index = selectedIndices.first,
              let image = scannedImages[safe: index] else {
            return nil
        }
        
        return image.jpegData(compressionQuality: 0.8)
    }

    func exportFile() -> URL? {
        let fileName: String
        let fileData: Data?

        switch selectedExportFormat {
        case .pdf:
            print("PDF 저장")
            fileName = "scanned.pdf"
            fileData = createPDF()
        case .jpeg:
            print("JPEG 저장")
            fileName = "scanned.jpg"
            fileData = createJPEG()
        case .none:
            return nil
        }

        guard let data = fileData else { return nil }
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return url
        } catch {
            print("파일 저장 실패: \(error)")
            return nil
        }
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
