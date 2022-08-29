//
//  ViewModel.swift
//  ScrollReaderTest
//
//  Created by Taehyung Lee on 2022/08/29.
//

import Foundation
import SwiftUI

enum ScrollState {
    case prevLoad
    case nextLoad
    case addLoad
}

class ViewModel:ObservableObject {
    
    @Published var list:[TestModel] = []
    @Published var scrollTarget:UUID?
    
    @Published var scrollState:ScrollState = .addLoad
    
    let pagingCnt = 20
    init() {
        for i in 0..<pagingCnt {
            let str = "TEST ------- \(i)"
            list.append(TestModel(titleStr: str))
            
        }
        self.scrollTarget = self.list.last?.id
    }
    
    func appendPrevItem() {
        print("appendPrevItem")
        scrollState = .prevLoad
        var prevList:[TestModel] = []
        for i in 0..<pagingCnt {
            let str = "--Prev Item \(i)--"
            prevList.append(TestModel(titleStr: str))
        }
        self.scrollTarget = self.list.first?.id
        prevList.append(contentsOf: self.list)
        self.list = prevList
    }
    
    func appendNextItem() {
        print("appendNextItem")
        scrollState = .nextLoad
        self.scrollTarget = self.list.last?.id
        var nextList:[TestModel] = []
        for i in 0..<pagingCnt {
            let str = "--Next Item \(i)--"
            nextList.append(TestModel(titleStr: str))
        }
        self.list.append(contentsOf: nextList)
    }
    
    func addItem() {
        scrollState = .addLoad
        let str = "TEST ------- \(list.count)"
        list.append(TestModel(titleStr: str))
        
        self.scrollTarget = self.list.last?.id
        
    }
    
}
