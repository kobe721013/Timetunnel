//
//  CellData.swift
//  Timetunnel
//
//  Created by Kobe on 2017/12/5.
//  Copyright © 2017年 kobe. All rights reserved.
//

import Foundation
struct CellData : Codable //for save
{
    var dateTime:String!
    var text:String?
    var photos = [PhotoInfo]()
    
    
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    static func save2File(cellDatas:[CellData])
    {
        let propertyEnCoder = PropertyListEncoder()
        if let data = try? propertyEnCoder.encode(cellDatas) {
            let url = CellData.documentsDirectory.appendingPathComponent("AllCellData")
            try? data.write(to: url)
        }
    }
    
    static func readAllCellDataFromFile() -> [CellData]?
    {
        let propertyDecoder = PropertyListDecoder()
        let url = CellData.documentsDirectory.appendingPathComponent("AllCellData")
        if let data = try? Data(contentsOf: url), let cellsData = try? propertyDecoder.decode([CellData].self, from: data){
            return cellsData
        }
        else {
            return nil
        }
        
    }
}



struct CellId {
    static let Cell_1P = "1Pcell"
    static let Cell_2P = "2Pcell"
    static let Cell_3P = "3Pcell"
}
