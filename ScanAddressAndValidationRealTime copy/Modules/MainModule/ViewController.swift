//
//  ViewController.swift
//  ScanAddressAndValidationRealTime
//

import UIKit
import VisionKit
import Vision
import CoreLocation
import MapKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet private weak var choseImageButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var placholderImageView: UIImageView!
    @IBOutlet private weak var outputTextLabel: UILabel!
    @IBOutlet private weak var outputTextContentView: UIView!
    @IBOutlet private weak var locationImageView: UIImageView!
    @IBOutlet private weak var openMapButton: UIButton!
    
    private var geocoder = CLGeocoder()
    private var imagePicker = UIImagePickerController()
    private var actualAddress: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsOutputTextContentView()
        isHiddenOpenMapButton(isHidden: true)
    }
    
    private func settingsOutputTextContentView() {
        outputTextContentView.backgroundColor = Colors.brandGray
        outputTextContentView.layer.cornerRadius = 16
    }
    
    @IBAction func choseImageButtonDidTap(_ sender: Any) {
        ImagePickerManager().pickImage(self) { image in
            self.imageView.image = image
            self.isHiddenPlacholderImageView()
            self.setupVision()
        }
    }
    
    @IBAction func openMapButtonAction(_ sender: Any) {
        openCoordinatesMapView(address: actualAddress)
    }
    
    private func setupVision() {
        // converting image into CGImage
        guard let cgImage = imageView.image?.cgImage else { return }
        
        // creating request with cgImage
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Vision provides its text-recognition capabilities through VNRecognizeTextRequest, an image-based request type that finds and extracts text in images.
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
            
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")
            
            print("✅",text) // text we get from image
            
            let searchAddressInText = self.searchAddressInText(inputText: text) // func for serch address Type in text
            print("✅",searchAddressInText as Any)
            
            self.outputTextLabel.text = searchAddressInText
            self.checkAddressInRealTime(address: searchAddressInText ?? "")
        }
        
        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
        try? handler.perform([request])
    }
    
    private func checkAddressInRealTime(address: String) {
        let successAlertTitle = "Your address successfully was found!"
        let errorAlertTitle = "Sorry, but we cannot find this address."
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first {
                let latitude = placemark.location?.coordinate.latitude
                let longitude = placemark.location?.coordinate.longitude
                let configureResult: String = "📍Latitude: \(latitude ?? 0)\n📍Longitude: \(longitude ?? 0)"
                
                self.showSuccessAlertForResultRequet(title: successAlertTitle, message: configureResult) {
                    self.openCoordinatesMapView(address: address)
                    self.actualAddress = address
                    self.isHiddenOpenMapButton(isHidden: false)
                    // - TODO
                    // self.openGoogleMap(latitude: latitude ?? 0, longitude: longitude ?? 0)
                }
                print("✅", configureResult)
            }
            
            if let error = error {
                self.showErrorAlertForResultRequet(title: errorAlertTitle)
                self.isHiddenOpenMapButton(isHidden: true)
                print("❌", error)
            }
            
        }
    }
}

// MARK: - extension for work with map
extension ViewController {
    
    // MARK: - TO DO
    //    private func openGoogleMap(latitude: Double, longitude: Double, address: String) {
    // Apple Maps
    //        let regionDistance:CLLocationDistance = 10000
    //        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
    //        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
    //        let options = [
    //            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
    //            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
    //        ]
    //        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
    //        let mapItem = MKMapItem(placemark: placemark)
    //        mapItem.name = address
    //        mapItem.openInMaps(launchOptions: options)
    
    // Google Maps
    //        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")! as URL)) {
    //            UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")! as URL)
    //
    //        } else {
    //            print("Can't use comgooglemaps://");
    //        }
    //    }
}

extension ViewController {
    
    private func isHiddenPlacholderImageView() {
        placholderImageView.isHidden = imageView == nil ? false : true
    }
    
    private func isHiddenOpenMapButton(isHidden: Bool) {
        openMapButton.isHidden = isHidden ? true : false
        locationImageView.isHidden = openMapButton.isHidden
    }
    
    private  func openCoordinatesMapView(address: String) {
        let mapViewController = MapViewController(address: address)
        present(mapViewController, animated: true)
    }
}

// extension for custome Alert
extension ViewController {
    
    private func showErrorAlertForResultRequet(title: String) {
        let alert = CustomeAlert()
        alert.alertTitle = title
        alert.okButtonTitle = "Close"
        alert.isCancelButtonHidden = true
        alert.statusImage = UIImage(named: "notLocation")
        alert.show()
    }
    
    private func showSuccessAlertForResultRequet(title: String, message: String, handler: (() -> Void)?) {
        let alert = CustomeAlert()
        alert.alertTitle = title
        alert.alertMessage = message
        alert.okButtonTitle = "Open Map"
        alert.cancelButtonTitle = "Cancel"
        alert.statusImage = UIImage(named: "location")
        alert.okHandler = handler
        alert.show()
    }
}

extension ViewController {
    
    // Func for serch address in input Text
    private func searchAddressInText(inputText: String) -> String? {
        var foundAddress: Substring = ""
        let detectorType: NSTextCheckingResult.CheckingType = [.address]
        
        do {
            let detector = try NSDataDetector(types: detectorType.rawValue)
            let results = detector.matches(in: inputText, options: [], range: NSRange(location: 0, length: inputText.utf16.count))
            
            for result in results {
                if let range = Range(result.range, in: inputText) {
                    let matchResult = inputText[range]
                    foundAddress = matchResult
                    
                    print("✅ Address search result: \(matchResult), range: \(result.range)")
                }
            }
            
        } catch {
            print("❌ Handle Error")
        }
        
        return String(foundAddress)
    }
}
