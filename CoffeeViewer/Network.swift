//
//  Network.swift
//  CoffeeViewer
//
//  Created by Kevin Chan on 2016/12/21.
//  Copyright © 2016年 Kevinjay Chan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Deferred
import CoreData

struct Network {

    @discardableResult
    static func fetchCoffeeShopDetail() -> Deferred<Result<[CoffeeShop]>> {

        let container = AppDelegate.container
        let promise = Deferred<Result<[CoffeeShop]>>()

        Alamofire.request("https://cafenomad.tw/api/v1.0/cafes").responseJSON { (response) in

            switch response.result {
            case .success(let result):

                container.viewContext.perform {
                    let context = container.viewContext
                    var shops = [CoffeeShop]()
                    let json = JSON(result)
                    for raw in json {

                        let data = raw.1
                        guard let id = data["id"].string else {
                            continue
                        }

                        let fetch: NSFetchRequest<CoffeeShop> = CoffeeShop.fetchRequest()
                        fetch.predicate = NSPredicate(format: "id == %@", id)

                        do {
                            let shopsGroup = try context.fetch(fetch)
                            let shop: CoffeeShop

                            if let oldData = shopsGroup.first {
                                shop = oldData
                            } else {
                                shop = CoffeeShop(context: context)
                            }

                            shop.id = id
                            shop.address = data["address"].string ?? ""
                            shop.city = data ["city"].string ?? ""
                            shop.name = data["name"].string ?? ""
                            shop.url = data["url"].string ?? ""
                            shop.latitude = Double(data["latitude"].stringValue) ?? 0.0
                            shop.longitude = Double(data["longitude"].stringValue) ?? 0.0
                            shop.foodTastyScore = data["tasty"].double ?? 0.0

                            shop.musicScore = data["music"].double ?? 0.0
                            shop.priceScore = data["cheap"].double ?? 0.0
                            shop.quietScore = data["quiet"].double ?? 0.0
                            shop.seatScore = data["seat"].double ?? 0.0
                            shop.wifiScore = data["wifi"].double ?? 0.0

                            shop.totalScore = shop.musicScore + shop.priceScore + shop.quietScore + shop.seatScore + shop.wifiScore
                            shops.append(shop)

                        } catch {
                            NSLog("Fetch Request Failed \(error)")
                            promise.fill(with: .failure(error))
                        }
                    }

                    promise.fill(with: .success(shops))
                }

            case .failure(let error):
                promise.fill(with: .failure(error))
            }

        }

        return promise
    }
}
