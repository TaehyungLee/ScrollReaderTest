//
//  ScrollReaderTestApp.swift
//  ScrollReaderTest
//
//  Created by Taehyung Lee on 2022/08/29.
//

import SwiftUI
import FirebaseCore

@main
struct ScrollReaderTestApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
        }
    }
}
