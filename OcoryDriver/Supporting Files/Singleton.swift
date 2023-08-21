//
//  Singleton.swift
//  OcoryDriver
//
//  Created by nile on 24/06/21.
//

import Foundation
import UIKit

class Singleton {
    
    static var shared: Singleton? = Singleton()
    
    private init() {
        
    }
    
    deinit {
        print(#file , " Destructed")
    }
    let title = "GetDuma Driver"
    var customerData : userCustomerModal?

    
    
}

