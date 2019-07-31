//
//  Task.swift
//  HomeSpace
//
//  Created by axiom1234 on 13/03/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CodableFirebase

extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}

struct Task : Codable {
    
    let date : Timestamp?
    let name : String?
    var id : String? = ""
    var rank: Double? = 0
    var group: String? = ""
    var reminder:String? = ""
    
    
    
    static var shared = [String:[Task]]()
    
    init(name:String, date: Date, group: String) {
        self.name = name
        self.date = Timestamp(date: date)
        self.group = group
    }
    
    var toDic: [String:Any]{
        return[
            "name":self.name ?? "",
            "date":self.date ?? Date(),
            "rank":self.rank ?? 0,
            "group":self.group ?? "",
            "reminder":self.reminder ?? ""
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case name = "name"
        case rank = "rank"
        case group = "group"
        case reminder = "reminder"

    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        date = try values.decodeIfPresent(Timestamp.self, forKey: .date)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        rank = try values.decodeIfPresent(Double.self, forKey: .rank)
        group = try values.decodeIfPresent(String.self, forKey: .group)
        reminder = try values.decodeIfPresent(String.self, forKey: .reminder)
    }
    
    

    
}