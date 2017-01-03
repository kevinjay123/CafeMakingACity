//
//  CoffeeShopExtension.swift
//  CoffeeViewer
//
//  Created by Kevin Chan on 2016/12/28.
//  Copyright © 2016年 Kevinjay Chan. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

extension CoffeeShop: MKAnnotation {

    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public var title: String? {
        return name
    }

    public var subtitle: String? {
        return address
    }

    public var shopId: String {
        return id!
    }
}
