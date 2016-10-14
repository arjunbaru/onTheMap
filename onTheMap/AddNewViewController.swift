//
//  AddNewViewController.swift
//  onTheMap
//
//  Created by Arjun Baru on 02/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import UIKit
import MapKit

class AddNewViewController: UIViewController ,UITextFieldDelegate, MKMapViewDelegate{
    
   var appDelegate : AppDelegate!
    var userLocation = [CLPlacemark]()
    var studentLocationName = ""
    var studentLat = CLLocationDegrees()
    var studentLong = CLLocationDegrees()
//    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var labelText: UILabel!

   @IBOutlet weak var OnTheMapButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var urlTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     setupView()
   
    }

   
    
    @IBAction func CancelButton(_ sender: AnyObject) {
        self.reach()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func findOnTheMap(_ sender: AnyObject) {
        self.reach()
        if locationTextField.text != "" {
            let geocoder = CLGeocoder()
            if let locationEntered = locationTextField.text {
                let activeView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                activeView.center = view.center
                activeView.startAnimating()
                view.addSubview(activeView)
                let views = [locationTextField!,OnTheMapButton!] as [Any]
                changeAlphaFor(views as! [UIView], alpha: 0.5)
                geocoder.geocodeAddressString(locationEntered){(placemark,error) in
                    if error != nil {
                        print("error is \(error)")
                        print("placemarkkk isss \(placemark)")
                        performUIUpdatesOnMain {
                            self.changeAlphaFor(views as! [UIView], alpha: 1.0)
                            activeView.stopAnimating()
                            let alert = UIAlertController(title: "Error",message: "Location Unknown",preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Dismis",style: .default,handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    self.userLocation = placemark!
                    self.configureMap()
                    self.changeUserInterface()
                    activeView.stopAnimating()
                }
            }
        }
        
    }

    @IBAction func submitButton(_ sender: UIButton) {
        self.reach()
        guard urlTextField.text != "" else{
            print("enter text ")
            return
        }
        let studentArray : [String : Any] = [
            parseClient.JSONBodyKeys.UniqueKey: appDelegate.userID ,
            parseClient.JSONBodyKeys.FirstName: appDelegate.userDetails[0],
            parseClient.JSONBodyKeys.LastName: appDelegate.userDetails[1],
            parseClient.JSONBodyKeys.MapString: studentLocationName,
            parseClient.JSONBodyKeys.MediaURL: urlTextField.text!,
            parseClient.JSONBodyKeys.Latitude: studentLat,
            parseClient.JSONBodyKeys.Longitude: studentLong
        ]
        
       if self.appDelegate.objectID == "" {
            
            parseClient.sharedInstance().postStudentLocation(studentArray){(result,network,error) in
               
        
                    if network != true{
                        self.serverError()
                    }else if result != nil{
                
                self.appDelegate.objectID = result! as! String
                print("object ID is  \(self.appDelegate.objectID)")
                performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
                }
                    print("error occured: \(error)")
                
           }
       } else if self.appDelegate.objectID != ""{
            print("THIS GET CALLED")
            parseClient.sharedInstance().putStudentLocation(self.appDelegate.objectID,studentArray){(result,network,error) in
                 print(" it is hererere\(result)")
              if network != true {
                self.serverError()
              }else if result != nil {
                performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    
        }
    }
    //setting pin on map
    func configureMap(){
        let topPLacementResult = userLocation[0]
        let placemarkToPlace = MKPlacemark(placemark: topPLacementResult)
        studentLocationName = placemarkToPlace.name!
        studentLat = placemarkToPlace.coordinate.latitude
        studentLong = placemarkToPlace.coordinate.longitude
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(studentLat, studentLong)
       let pinCoordinate = CLLocationCoordinate2DMake(studentLat, studentLong)
        
    let span = MKCoordinateSpanMake(0.1, 0.1)
         let region = MKCoordinateRegionMake(pinCoordinate, span)
        performUIUpdatesOnMain {
            self.mapView.addAnnotation(annotation)
           self.mapView.setRegion(region, animated: true)
            self.mapView.regionThatFits(region)
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pined") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pined")
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }else{
            pinView!.annotation = annotation
        }
        return pinView
    }
    
   
}


extension AddNewViewController{
    
    func changeUserInterface(){
        self.locationTextField.isHidden = true
        self.mapView.isHidden = false
        self.OnTheMapButton.isHidden = true
        self.submitButton.isHidden = false
        self.urlTextField.isHidden = false
        self.labelText.text = "Your LinkedIn ID"
        
    }
   func setupView(){
    appDelegate = UIApplication.shared.delegate as! AppDelegate
    self.mapView.isHidden = true
    self.submitButton.isHidden = true
    self.urlTextField.isHidden = true
    self.locationTextField.delegate = self
    self.urlTextField.delegate = self
    self.labelText.text = "Your Location?"
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.locationTextField.resignFirstResponder()
        self.urlTextField.resignFirstResponder()
        return true
    }
    
    func changeAlphaFor(_ views: [UIView], alpha: CGFloat){
        
        for view in views{
            view.alpha = alpha
        }
    }
    
    func reach(){
        Reachability.isConnectedToNetwork(){(x) in
            print("value is \(x)")
            if x == false {
                performUIUpdatesOnMain {
                    self.networkError()
                }
            }
        }
    }

    
    func networkError(){
        
        let alert = UIAlertController(title: "Error",message: "Unable To Connect To Internet",preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss" ,style: .default,handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    func serverError(){
        performUIUpdatesOnMain {
            let alert = UIAlertController(title: "Error",message: "Unable to complete the Request",preferredStyle: UIAlertControllerStyle.alert)
            let retry = UIAlertAction(title:"Retry",style: .default){(acton) in
                self.submitButton(self.submitButton)
            }
            alert.addAction(UIAlertAction(title: "Dismiss" ,style: .default,handler: nil))
            alert.addAction(retry)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
