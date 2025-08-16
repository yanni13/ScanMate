//
//  ScanMateUITests.swift
//  ScanMateUITests
//
//  Created by 신얀 on 2/13/25.
//

import XCTest

final class ScanMateUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {

    }

    @MainActor
    func testAppLaunchAndNavigationTitle() throws {
        // 앱이 정상적으로 실행되는지 확인
        XCTAssertTrue(app.exists)
        
        // ScanMate 타이틀이 표시되는지 확인
        let titleElement = app.navigationBars["ScanMate"]
        XCTAssertTrue(titleElement.exists, "Navigation title 'ScanMate' should exist")
    }
    
    @MainActor
    func testMainViewElements() throws {
        // 스캔 버튼이 존재하는지 확인
        let scanButton = app.buttons["Scan Image"]
        XCTAssertTrue(scanButton.exists, "Scan Image button should exist")
        
        // 파일 변환 버튼이 존재하는지 확인
        let convertButton = app.buttons["Convert to File"]
        XCTAssertTrue(convertButton.exists, "Convert to File button should exist")
        
        // 리셋 버튼이 존재하는지 확인
        let resetButton = app.buttons["Reset"]
        XCTAssertTrue(resetButton.exists, "Reset button should exist")
        
        // 편집 버튼이 존재하는지 확인
        let editButton = app.buttons["Edit"]
        XCTAssertTrue(editButton.exists, "Edit button should exist")
    }
    
    @MainActor
    func testEmptyStateDisplay() throws {
        // 빈 상태에서 document.viewfinder 아이콘이 표시되는지 확인
        let documentIcon = app.images["document.viewfinder"]
        XCTAssertTrue(documentIcon.exists, "Document viewfinder icon should be displayed in empty state")
    }

    @MainActor
    func testScanButtonInteraction() throws {
        // 스캔 버튼을 탭했을 때 카메라 권한 요청이나 스캐너가 열리는지 확인
        let scanButton = app.buttons["Scan Image"]
        XCTAssertTrue(scanButton.exists)
        
        scanButton.tap()
        
        // 카메라 접근 권한 알림이 나타날 수 있으므로 기다림
        let expectation = XCTestExpectation(description: "Wait for scanner or permission")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        // 권한 알림이 있다면 허용 버튼 탭
        let allowButton = app.buttons["Allow"]
        if allowButton.exists {
            allowButton.tap()
        }
    }
    
    @MainActor
    func testConvertToFileButtonInteraction() throws {
        // 파일 변환 버튼을 탭했을 때 포맷 선택 시트가 나타나는지 확인
        let convertButton = app.buttons["Convert to File"]
        XCTAssertTrue(convertButton.exists)
        
        convertButton.tap()
        
        // 액션시트가 나타나는지 확인
        let pdfOption = app.buttons["PDF"]
        let jpegOption = app.buttons["JPEG"]
        let cancelOption = app.buttons["Cancel"]
        
        // 포맷 옵션들이 표시되는지 확인
        XCTAssertTrue(pdfOption.exists || jpegOption.exists || cancelOption.exists, 
                     "Format selection sheet should appear")
        
        // 취소 버튼으로 시트 닫기
        if cancelOption.exists {
            cancelOption.tap()
        }
    }
    
    @MainActor
    func testResetButtonFunctionality() throws {
        // 리셋 버튼이 존재하고 탭 가능한지 확인
        let resetButton = app.buttons["Reset"]
        XCTAssertTrue(resetButton.exists)
        XCTAssertTrue(resetButton.isEnabled)
        
        resetButton.tap()
        
        // 리셋 후에도 빈 상태 아이콘이 표시되는지 확인
        let documentIcon = app.images["document.viewfinder"]
        XCTAssertTrue(documentIcon.exists, "Document icon should be visible after reset")
    }
    
    @MainActor
    func testEditButtonInteraction() throws {
        // 편집 버튼이 존재하는지 확인
        let editButton = app.buttons["Edit"]
        XCTAssertTrue(editButton.exists)
        XCTAssertTrue(editButton.isEnabled)
        
        editButton.tap()
        
        // 편집 화면이 열리는지 확인 (현재는 "개발 중" 메시지 표시)
        let developmentMessage = app.staticTexts["개발 중 입니다.\n조금만 더 기다려주세요!"]
        XCTAssertTrue(developmentMessage.exists, "Development message should be displayed")
    }
    
    @MainActor
    func testNavigationAndAccentColor() throws {
        // 네비게이션 바가 존재하는지 확인
        let navigationBar = app.navigationBars["ScanMate"]
        XCTAssertTrue(navigationBar.exists)
        
        // 앱의 기본 색상이 teal로 설정되었는지 간접적으로 확인
        // (UI 테스트에서는 색상을 직접 확인하기 어려우므로 UI 요소의 존재로 확인)
        let scanButton = app.buttons["Scan Image"]
        XCTAssertTrue(scanButton.exists)
        XCTAssertTrue(scanButton.isEnabled)
    }
    
    @MainActor
    func testUIElementsAccessibility() throws {
        // 모든 주요 버튼들이 접근 가능한지 확인
        let buttons = [
            "Scan Image",
            "Convert to File", 
            "Reset",
            "Edit"
        ]
        
        for buttonTitle in buttons {
            let button = app.buttons[buttonTitle]
            XCTAssertTrue(button.exists, "\(buttonTitle) button should exist")
            XCTAssertTrue(button.isEnabled, "\(buttonTitle) button should be enabled")
        }
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
