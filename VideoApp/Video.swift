//
//  Video.swift
//  VideoApp
//
//  Created by Gabriel Vieira on 4/8/17.
//  Copyright © 2017 Gabriel Vieira. All rights reserved.
//

import Foundation
import ObjectMapper

class Video: Mappable {
    var name: String?
    var thumb: String?
    var url: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        thumb <- map["thumb"]
        url <- map["url"]
    }
}
