//
//  ViewModel.swift
//  ScrollReaderTest
//
//  Created by Taehyung Lee on 2022/08/29.
//

import Foundation
import SwiftUI
//import FirebaseDatabase
import FirebaseStorage  // for saving image to Storage
import FirebaseFirestore
import FirebaseFirestoreSwift

import Combine

enum ScrollState {
    case prevLoad
    case nextLoad
    case recentLoad
    case addLoad
}

class ViewModel:ObservableObject {
    
    @Published var list:[WineData] = []
    @Published var scrollTarget:UUID?
    
    @Published var scrollState:ScrollState = .addLoad
    
    let db = Firestore.firestore()
    
    let pagingCnt = 5
    var nextQuary:Query?
    
    var storeCancellable = Set<AnyCancellable>()
    
    init() {
        
    }
    
    /// 기존 데이터 초기화하고 최신 리스트 로드
    func appendRecentItem() {
        self.list.removeAll()
        self.nextQuary = nil
        
        self.wineDataFetch()
            .sink { emitValue in
                print("appendRecentItem complete : \(emitValue)")
            } receiveValue: { list in
                self.list = list.map({ model in
                    WineData(model: model)
                })
                self.scrollTarget = self.list.last?.id
            }.store(in: &storeCancellable)
        
    }
    
    
    /// 이전 데이터 불러오기
    func appendPrevItem() {
        print("appendPrevItem")
        scrollState = .prevLoad
        
        self.wineDataFetch()
            .sink { emitValue in
                print("complete : \(emitValue)")
            } receiveValue: { list in
                var prevList:[WineData] = []
                prevList = list.map({ model in
                    WineData(model: model)
                })

                self.scrollTarget = self.list.first?.id
                prevList.append(contentsOf: self.list)
                self.list = prevList
            }.store(in: &storeCancellable)
    }
    
    /// 다음 데이터 불러오기
    func appendNextItem() {
        print("appendNextItem")
        scrollState = .nextLoad
        self.wineDataFetch()
            .sink { emitValue in
                print("appendNextItem complete : \(emitValue)")
            } receiveValue: { list in
                self.scrollTarget = self.list.last?.id
                var nextList:[WineData] = []
                nextList = list.map({ model in
                    WineData(model: model)
                })

                self.list.append(contentsOf: nextList)
            }.store(in: &storeCancellable)
        
    }
    
    /// firebase 를 통해서 데이터 가져오기
    /// - Returns: 네트워크 통신 응답이 왔을때 publisher를 통해 값 전달
    func wineDataFetch() -> Future<[WineDataModel], Error> {
        print("wineDataFetch")
        return Future<[WineDataModel], Error> { promise in
            let first:Query = self.nextQuary ?? self.db.collection("wines")
                .order(by: "koreanName")
                .limit(to: self.pagingCnt)
            first.addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error retreving cities: \(error.debugDescription)")
                    return
                }
                
                guard let lastSnapshot = snapshot.documents.last else {
                    // The collection is empty.
                    return
                }
                
                // Construct a new query starting after this document,
                // retrieving the next 25 cities.
                self.nextQuary = self.db.collection("wines")
                    .order(by: "koreanName")
                    .start(afterDocument: lastSnapshot)
                
                // Use the query for pagination.
                if let err = error {
                    print("Error getting documents: \(err)")
                } else {
                    do {
                        var resultList:[WineDataModel] = []
                        for document in snapshot.documents {
                            let data = try JSONSerialization.data(withJSONObject: document.data(), options: [.fragmentsAllowed])
                            let wineModel:WineDataModel = try JSONDecoder().decode(WineDataModel.self, from:data)
                            resultList.append(wineModel)

                        }
                        promise(.success(resultList))
                        
                    } catch (let error) {
                        promise(.failure(error))
                        print("Error Decoder : \(error.localizedDescription)")
                    }
                    
                }
            }
            
            
        }
        
        
        
    }
    
    /// 데이터 추가
    func addItem() {
//        scrollState = .addLoad
//        let str = "TEST ------- \(list.count)"
//        list.append(TestModel(titleStr: str))
//
//        self.scrollTarget = self.list.last?.id
        
    }
    
    
}
