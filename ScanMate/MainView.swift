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
            TabView {
                ScanView()                    .tabItem {
                        Image(systemName: "document.viewfinder")
                        Text("Scan")
                    }
                
                Text("Files")
                    .tabItem {
                        Image(systemName: "folder")
                        Text("Files")
                    }
            }
            .navigationBarTitle("ScanMate", displayMode: .inline)
            .accentColor(.teal)

        }
    }
}

#Preview {
    MainView()
}
