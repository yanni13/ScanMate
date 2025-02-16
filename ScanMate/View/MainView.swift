//
//  MainView.swift
//  ScanMate
//
//  Created by 신얀 on 2/13/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            ScanView()
            
            .navigationBarTitle("ScanMate", displayMode: .inline)
            .accentColor(.teal)
            
        }
    }
}

#Preview {
    MainView()
}
