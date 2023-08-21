//
//  ServicesModal.swift
//  OcoryDriver
//
//  Created by nile on 29/09/21.
//

import Foundation
struct ServicesModel : Codable {
    let id : String?
    let status : String?
    let title : String?
    let service_id : String?

    let vehicle_type : String?
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case status = "status"
        case title = "title"
        case vehicle_type = "vehicle_type"
        case service_id = "service_id"
        
    }
}
typealias selectServicesModal = [ServicesModel]
