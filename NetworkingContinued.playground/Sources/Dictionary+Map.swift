//
//  Dictionary+Map.swift
//  Luna
//
//  Created by Andrew Shepard on 4/28/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

import Foundation

extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}

extension Dictionary {
    func map<OutKey: Hashable, OutValue>(transform: Element -> (OutKey, OutValue)) -> [OutKey: OutValue] {
        return Dictionary<OutKey, OutValue>(Swift.map(self, transform))
    }
    
    func filter(includeElement: Element -> Bool) -> [Key: Value] {
        return Dictionary(Swift.filter(self, includeElement))
    }
}
