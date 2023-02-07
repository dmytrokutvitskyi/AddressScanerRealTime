//
//  MapViewController.swift
//  ScanAddressAndValidationRealTime
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let address: String
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var dismissButton: UIButton!
    
    private let geocoder = CLGeocoder()
    
    init(address: String) {
        self.address = address
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openMapWithAddress()
        setupButton()
    }
    
    private func openMapWithAddress() {
        geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                
                let mark = MKPlacemark(placemark: placemark)
                
                if var region = self?.mapView.region {
                    region.center = location.coordinate
                    region.span.longitudeDelta /= 8.0
                    region.span.latitudeDelta /= 8.0
                    self?.mapView.setRegion(region, animated: true)
                    self?.mapView.addAnnotation(mark)
                }
            }
        }
    }
    
    private func setupButton() {
        dismissButton.layer.cornerRadius = 5
    }
    
    @IBAction func dismissMapButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
}
