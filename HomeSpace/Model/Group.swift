//
//  Group.swift
//  HomeSpace
//
//  Created by Admin on 19/09/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CodableFirebase

struct Group : Codable,Hashable,Equatable {
    
    let date : Timestamp?
    var name : String?
    var id : String? = ""
    var uid: String?
    
    
    
    static var shared = [String:Group]()
    
    init(name:String, date: Date, uid:String) {
        self.name = name
        self.date = Timestamp(date: date)
        self.uid  = uid
    }
    
    var toDic: [String:Any]{
        return[
            "name":self.name ?? "",
            "date":self.date ?? Date(),
            "uid" :self.uid ?? ""
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case name = "name"
        case uid  = "uid"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        date = try values.decodeIfPresent(Timestamp.self, forKey: .date)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        uid  = try values.decodeIfPresent(String.self, forKey: .uid)
    }
  
    static func ==(lhs: Group, rhs: Group) -> Bool {
        return lhs.id == rhs.id 
    }
}
