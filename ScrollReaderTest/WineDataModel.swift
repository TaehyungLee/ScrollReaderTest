//
//  WineDataModel.swift
//  WineExplore
//
//  Created by Taehyung Lee on 2022/05/02.
//

import UIKit

struct WineDataModel:Codable {
    var koreanName:String? = ""
    var originName:String? = ""
    var country:String? = ""
    var region1:String? = ""
    var region2:String? = ""
    var price:Int? = 0
    
}

struct WineData:Identifiable, Hashable {
    var id = UUID()
    
    var koreanName = ""
    var originName = ""
    var country = ""
    var region1 = ""
    var region2 = ""
    var price = 0
    
    init(model:WineDataModel) {
        
        self.koreanName = model.koreanName ?? ""
        self.originName = model.originName ?? ""
        self.country = model.country ?? ""
        self.region1 = model.region1 ?? ""
        self.region2 = model.region2 ?? ""
        self.price = model.price ?? 0
    }
}
