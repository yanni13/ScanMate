//
//  Collection.swift
//  ScanMate
//
//  Created by 신얀 on 2/16/25.
//

// 배열 안전 접근을 위한 extension
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
