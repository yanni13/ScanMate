//
//  Array.swift
//  ScanMate
//
//  Created by 신얀 on 2/17/25.
//

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
