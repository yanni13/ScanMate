//
//  ImageSelectionView.swift
//  ScanMate
//
//  Created by 신얀 on 2/13/25.
//

import SwiftUI
import UIKit

struct ImageSelectionView: View {
    let image: UIImage
    let isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(8)
                .shadow(radius: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                )
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
                .background(Circle().fill(.white))
                .padding(8)
        }
    }
}
