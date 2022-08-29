//
//  TestModel.swift
//  ScrollReaderTest
//
//  Created by Taehyung Lee on 2022/08/29.
//

import Foundation

struct TestModel:Identifiable, Hashable {
    var id = UUID()
    var title = ""
    
    init(titleStr:String) {
        self.title = titleStr
    }
    
}
