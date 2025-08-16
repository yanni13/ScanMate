//
//  ScanMateTests.swift
//  ScanMateTests
//
//  Created by 신얀 on 2/13/25.
//

import Testing
import SwiftUI
import iOSSnapshotTestCase
import XCTest
@testable import ScanMate

struct ScanMateTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

final class ScanMateSnapshotTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        // 처음 실행 시에는 아래 라인의 주석을 해제하여 기준 이미지를 생성하세요
         recordMode = true
    }
    
    func testMainViewSnapshot() {
        let mainView = MainView()
        let hostingController = UIHostingController(rootView: mainView)
        
        // 뷰 크기 설정
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812) // iPhone 15 Pro 크기
        
        FBSnapshotVerifyView(hostingController.view, identifier: "MainView-iPhone15Pro")
    }
    
    func testScanViewEmptyStateSnapshot() {
        let scanView = ScanView()
        let hostingController = UIHostingController(rootView: scanView)
        
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        
        FBSnapshotVerifyView(hostingController.view, identifier: "ScanView-EmptyState")
    }
    
    func testMainViewDarkModeSnapshot() {
        let mainView = MainView()
            .preferredColorScheme(.dark)
        let hostingController = UIHostingController(rootView: mainView)
        
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        
        // 다크 모드 설정
        hostingController.overrideUserInterfaceStyle = .dark
        
        FBSnapshotVerifyView(hostingController.view, identifier: "MainView-DarkMode")
    }
    
    func testScanViewWithButtonsSnapshot() {
        let scanView = ScanView()
        let hostingController = UIHostingController(rootView: scanView)
        
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        
        // 뷰가 완전히 로드될 때까지 기다림
        let expectation = self.expectation(description: "View loaded")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
        FBSnapshotVerifyView(hostingController.view, identifier: "ScanView-WithButtons")
    }
}
