//
//  ShopDetailViewController.swift
//  CoffeeViewer
//
//  Created by Kevin Chan on 2017/1/3.
//  Copyright © 2017年 Kevinjay Chan. All rights reserved.
//

import UIKit
import Cosmos
import SafariServices
import MapKit
import CoreLocation

class ShopDetailViewController: UIViewController {

    var shop: CoffeeShop!
    var currentLocation: CLLocation!
    @IBOutlet var starRatingView: [CosmosView]!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var routingButton: UIButton!

    private var backgroundView: UIView? {
        didSet {

            if let view = backgroundView {

                oldValue?.removeFromSuperview()

                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                view.frame = self.view.bounds

                self.view.insertSubview(view, at: 0)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = shop.name

        backgroundView = UIImageView(image: #imageLiteral(resourceName: "paper"))
        websiteButton.layer.cornerRadius = 5.0
        routingButton.layer.cornerRadius = 5.0

        starRatingView.forEach { (starView) in
            starView.settings.updateOnTouch = false
            starView.settings.fillMode = .half
        }

        if let url = shop.url, url.isEmpty {
            websiteButton.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        starRatingView.forEach { (starView) in
            switch starView.tag {
            case 0:
                starView.rating = shop.wifiScore
            case 1:
                starView.rating = shop.priceScore
            case 2:
                starView.rating = shop.quietScore
            case 3:
                starView.rating = shop.seatScore
            case 4:
                starView.rating = shop.musicScore
            case 5:
                starView.rating = shop.foodTastyScore
            default:break
            }
        }
    }

    @IBAction func websiteButtonDown(_ sender: UIButton) {

        if let urlstr = shop.url, let url = URL(string: urlstr) {
            let controller = SFSafariViewController(url: url)
            present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func routingButtonDown(_ sender: UIButton) {

        let currentPlace = MKPlacemark(coordinate: currentLocation.coordinate, addressDictionary: nil)
        let targetPlace = MKPlacemark(coordinate: CLLocation(latitude: shop.latitude, longitude: shop.longitude).coordinate, addressDictionary: nil)

        let currentMapItem = MKMapItem(placemark: currentPlace)
        let targetMapItem = MKMapItem(placemark: targetPlace)
        currentMapItem.name = "我的位置"
        targetMapItem.name = shop.name

        let routes = [currentMapItem, targetMapItem]

        let opions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        MKMapItem.openMaps(with: routes, launchOptions: opions)
    }
}
