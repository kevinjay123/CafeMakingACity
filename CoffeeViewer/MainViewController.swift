//
//  MainViewController.swift
//  CoffeeViewer
//
//  Created by Kevin Chan on 2016/12/21.
//  Copyright © 2016年 Kevinjay Chan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MainViewController: UIViewController {

    var shops = [CoffeeShop]()
    var nearShops = [CoffeeShop]()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var isMapMoved: Bool = false
    let container = AppDelegate.container

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var infoPanel: InfoPanel!

    override func viewDidLoad() {

        super.viewDidLoad()
        mapView.delegate = self
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.barTintColor = UIColor(red: 200.0 / 255.0, green: 100.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
        navigationItem.rightBarButtonItem?.isEnabled = false
        showInfoPanel(show: false)

        let fetch: NSFetchRequest<CoffeeShop> = CoffeeShop.fetchRequest()

        Network.fetchCoffeeShopDetail().upon(.main) { (result) in
            switch result {
            case .success(_):

                self.container.viewContext.perform {
                    let context = self.container.viewContext
                    do {
                        self.shops = try context.fetch(fetch)
                    } catch {
                        NSLog("Failed to load Core Data: \(error)")
                    }
                }

            case .failure(let error):

                NSLog("Failed to load network data: \(error)")
                self.container.viewContext.perform {
                    let context = self.container.viewContext
                    do {
                        self.shops = try context.fetch(fetch)
                    } catch {
                        NSLog("Failed to load Core Data: \(error)")
                    }
                }
            }
        }

        self.presentAnnotation()
    }

    override func viewDidAppear(_ animated: Bool) {
        determineCurrentLocation()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ListSegue", !nearShops.isEmpty {
            let controller = segue.destination as! ShopListViewController
            controller.shops = nearShops
            controller.currentLocation = currentLocation
        }
    }

    func determineCurrentLocation()
    {
        guard let mapView = mapView, isViewLoaded, CLLocationManager.locationServicesEnabled() else {
            return
        }

        currentLocation = CLLocation()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        switch CLLocationManager.authorizationStatus() {

        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            break
        }

        mapView.showsUserLocation = true
    }

    func presentAnnotation() {

        guard !shops.isEmpty else {
            return
        }

        if !nearShops.isEmpty {
            nearShops = []
        }

        navigationItem.rightBarButtonItem?.isEnabled = true

        shops.forEach { (shop) in
            let shopLocation = CLLocation(latitude: shop.coordinate.latitude, longitude: shop.coordinate.longitude)
            let distance = currentLocation.distance(from: shopLocation)
            if distance < 3000 {
                nearShops.append(shop)
            }

            mapView.addAnnotations(nearShops)
        }
    }

    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    func showInfoPanel(show showPanel: Bool) {

        guard isViewLoaded else {
            return
        }

        infoPanel.infoPanelBottomConstraint.constant = showPanel ? 0 : infoPanel.bounds.height
        view.setNeedsLayout()

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func userLocationButtonDown(_ sender: UIButton) {
        isMapMoved = false
        showInfoPanel(show: false)
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 300, 300), animated: true)
    }
}

extension MainViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {

        if let currentLocation = currentLocation, !isMapMoved {
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 300, 300), animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if let annotation = annotation as? CoffeeShop {

            let identifier = "pin"

            let view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                dequeuedView.annotation = annotation
                dequeuedView.image = resizeImage(image: #imageLiteral(resourceName: "red_pin"), newWidth: 30)
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.image = resizeImage(image: #imageLiteral(resourceName: "red_pin"), newWidth: 30)
                view.canShowCallout = true

                let button = UIButton(type: .detailDisclosure)
                view.rightCalloutAccessoryView = button
            }

            return view
        }

        return nil
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if control == view.rightCalloutAccessoryView, let coordinate = view.annotation?.coordinate {
            let currentPlace = MKPlacemark(coordinate: currentLocation.coordinate, addressDictionary: nil)
            let targetPlace = MKPlacemark(coordinate: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).coordinate, addressDictionary: nil)

            let currentMapItem = MKMapItem(placemark: currentPlace)
            let targetMapItem = MKMapItem(placemark: targetPlace)
            currentMapItem.name = "我的位置"
            targetMapItem.name = (view.annotation?.title)!

            let routes = [currentMapItem, targetMapItem]

            let opions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
            MKMapItem.openMaps(with: routes, launchOptions: opions)
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        guard let annotation = view.annotation else {
            return
        }

        let shop = shops.filter({ (shop) -> Bool in
            shop.name == (annotation.title)!
        })

        guard let filterShop = shop.first else {
            return
        }

        isMapMoved = true
        showInfoPanel(show: true)
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(annotation.coordinate, 300, 300), animated: true)

        infoPanel.starRatingView.forEach { (starView) in
            switch starView.tag {
            case 0:
                starView.rating = filterShop.wifiScore
            case 1:
                starView.rating = filterShop.priceScore
            case 2:
                starView.rating = filterShop.quietScore
            case 3:
                starView.rating = filterShop.seatScore
            case 4:
                starView.rating = filterShop.musicScore
            case 5:
                starView.rating = filterShop.foodTastyScore
            default:
                break
            }
        }
    }
}

extension MainViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if case .authorizedWhenInUse = status {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        presentAnnotation()
    }
}

