//
//  ShopListViewControllerTableViewController.swift
//  CoffeeViewer
//
//  Created by Kevin Chan on 2016/12/29.
//  Copyright © 2016年 Kevinjay Chan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ShopListViewController: UITableViewController {

    fileprivate var sortType = SortType.totalScore
    fileprivate var _shops: [CoffeeShop] = []

    var shops: [CoffeeShop] {
        get {
            return _shops
        }
        set {
            _shops = newValue.sorted { $0.totalScore > $1.totalScore }
        }
    }

    var currentLocation: CLLocation!

    fileprivate enum SortType: Int {
        case wifi       = 0
        case music      = 1
        case seat       = 2
        case quiet      = 3
        case tasty      = 4
        case cheap      = 5
        case distance   = 6
        case totalScore = 7

        var name: String {
            switch self {
            case .wifi:  return "Wifi 穩定度"
            case .music: return "裝潢音樂"
            case .seat:  return "通常有位"
            case .quiet: return "安靜程度"
            case .tasty: return "咖啡好喝"
            case .cheap: return "價格便宜"
            case .distance: return "距離"
            case .totalScore: return "綜合評分"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "paper"))
    }

    override func viewWillAppear(_ animated: Bool) {

        navigationItem.rightBarButtonItem?.title = "排序依：" + sortType.name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shops.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let shop = shops[indexPath.row]

        switch sortType {
        case .distance:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.backgroundColor = .clear
            cell.textLabel?.text = shop.name

            let shopLocation = CLLocation(latitude: shop.coordinate.latitude, longitude: shop.coordinate.longitude)
            let distance = currentLocation.distance(from: shopLocation)
            let df = MKDistanceFormatter()
            df.unitStyle = .abbreviated
            cell.detailTextLabel?.text = df.string(fromDistance: distance)
            return cell
        case .totalScore:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.backgroundColor = .clear
            cell.textLabel?.text = shop.name
            cell.detailTextLabel?.text = "總分為 \(Float(shop.totalScore)) 分"
            return cell
        case .wifi:
            let ratingCell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingCell
            ratingCell.nameLabel.text = shop.name
            ratingCell.starView.rating = shop.wifiScore
            return ratingCell
        case .cheap:
            let ratingCell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingCell
            ratingCell.nameLabel.text = shop.name
            ratingCell.starView.rating = shop.priceScore
            return ratingCell
        case .music:
            let ratingCell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingCell
            ratingCell.nameLabel.text = shop.name
            ratingCell.starView.rating = shop.musicScore
            return ratingCell
        case .quiet:
            let ratingCell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingCell
            ratingCell.nameLabel.text = shop.name
            ratingCell.starView.rating = shop.quietScore
            return ratingCell
        case .seat:
            let ratingCell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingCell
            ratingCell.nameLabel.text = shop.name
            ratingCell.starView.rating = shop.seatScore
            return ratingCell
        case .tasty:
            let ratingCell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingCell
            ratingCell.nameLabel.text = shop.name
            ratingCell.starView.rating = shop.foodTastyScore
            return ratingCell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: "DetailSegue", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "DetailSegue" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }

            let controller = segue.destination as! ShopDetailViewController
            controller.shop = shops[indexPath.row]
            controller.currentLocation = currentLocation
        }
    }

    @IBAction func changeOrderAction(_ sender: UIBarButtonItem) {

        let title = "排序依..."
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let sortTypes: [SortType] = [.distance, .totalScore, .wifi, .cheap, .quiet, .seat, .music, .tasty]

        for type in sortTypes {
            let action = UIAlertAction(
                title: (type == sortType ? "✓ " : "") + type.name,
                style: UIAlertActionStyle.default,
                handler: { action -> Void in
                    self.sortType = type
                    switch type {
                    case .wifi:
                        self._shops = self.shops.sorted { $0.wifiScore > $1.wifiScore }
                    case .cheap:
                        self._shops = self.shops.sorted { $0.priceScore > $1.priceScore }
                    case .quiet:
                        self._shops = self.shops.sorted { $0.quietScore > $1.quietScore }
                    case .seat:
                        self._shops = self.shops.sorted { $0.seatScore > $1.seatScore }
                    case .music:
                        self._shops = self.shops.sorted { $0.musicScore > $1.musicScore }
                    case .tasty:
                        self._shops = self.shops.sorted { $0.foodTastyScore > $1.foodTastyScore }
                    case .totalScore:
                        self._shops = self.shops.sorted { $0.totalScore > $1.totalScore }
                    case .distance:
                        self._shops = self.shops.sorted {
                            let shop1Location = CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
                            let shop2Location = CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude)
                            return self.currentLocation.distance(from: shop1Location) < self.currentLocation.distance(from: shop2Location)
                        }
                    }

                    self.navigationItem.rightBarButtonItem?.title = "排序依：" + self.sortType.name
                    self.tableView.reloadData()
            })

            controller.addAction(action)
        }

        // add cancel action
        controller.addAction(
            UIAlertAction(
                title: "取消",
                style: .cancel,
                handler: nil
            )
        )

        present(controller, animated: true, completion: nil)
    }
}
