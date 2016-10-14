//
//  MapViewController.swift
//  onTheMap
//
//  Created by Arjun Baru on 02/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import UIKit
import MapKit
class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    var appDelegate: AppDelegate!
 //   @IBOutlet weak var pinButton: UIBarButtonItem!
    
    var s: [[String:AnyObject]] = []
    override func viewDidLoad() {
       
        super.viewDidLoad()
       appDelegate = UIApplication.shared.delegate as! AppDelegate
        }

    override func viewWillAppear(_ animated: Bool) {
        studentData()
        userdata()
        self.reach()
        
    }
   
    
    
    
    @IBAction func addingByPin(_ sender: AnyObject) {
      //  parseClient.sharedInstance().querryForStudent()
        self.reach()
       parseClient.getaStudentData(){(result,error) in
            if error != nil {
                print("error found \(error)")
            }
            if result?.count != 0{
                let resultArray = result![0]
                print("this is result Array\(resultArray)")
                let objectID = resultArray["objectId"] as? String
               print("\(objectID)")
                self.appDelegate.objectID = objectID!
                performUIUpdatesOnMain {
                   self.launchAlertView()
                }
                
                
            }else{
            performUIUpdatesOnMain {
            let AddNewViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewViewController")
            self.present(AddNewViewController!, animated: true, completion: nil)
                }
        }
        }
        
    }
    
    @IBAction func logoutButton(_ sender: UIButton) {
        self.logout()
    }
  
    
    func logout(){
        self.reach()
        udacityClient.sharedInstance().deleteSession(){(result , error) in
            if error != nil{
                print("error found ")
                return
            }
            performUIUpdatesOnMain {
               self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    func userdata(){
        udacityClient.getUserData(udacityClient.sharedInstance().sessionID!){(result,error) in
           // print(result![1])
           self.appDelegate.userDetails = result!
            print("this is my name \(self.appDelegate.userDetails[0])")
            
            
        }
    }
    
    
    
 
    
    
    func studentData(){
    
        parseClient.sharedInstance().codeForStudentData(){(result,network,error) in

                
            if !StudentInformation.studentData.isEmpty{
                StudentInformation.studentData.removeAll()
            }
           
            if error != nil{
                performUIUpdatesOnMain {
               let alert = UIAlertController(title: "Error",message: "Cannot Download Data",preferredStyle: UIAlertControllerStyle.alert)
                let retry = UIAlertAction(title: "Retry",style: .default ){(action) in
                    self.studentData()
                }
                alert.addAction(retry)
                self.present(alert, animated: true, completion: nil)
                }
            }              
            if error == nil {
                if network != true{
                    self.serverError()
                }
            
                if let Student = result{
                print("THIS WORKED !!!!!!!!!!!!")
            
           
               for s in Student{
                //recieving nil value in some generated latitudes
                if s["latitude"] != nil{
                  StudentInformation.studentData.append(StudentInformation(dictionary: s))
                   // print(s["latitude"])
                }
                }
                StudentInformation.studentData = StudentInformation.studentData.sorted() {$0.updatedAt.compare($1.updatedAt as Date) == ComparisonResult.orderedDescending}

                performUIUpdatesOnMain {
                self.applyingStudentDataOnMap()
            }
        }
            }else{
                print(" cannot recieve result : \(error)")
            }
        }
}

   func applyingStudentDataOnMap(){
     
        var annotations = [MKPointAnnotation]()
       
        for student in StudentInformation.studentData{
            let lat = CLLocationDegrees(student.latitude!)
            
           let long = CLLocationDegrees(student.longitude!)
           let coordinates = CLLocationCoordinate2D(latitude: lat,longitude: long)
            let first = student.firstName
            let last = student.lastName
            let mediaUrl = student.mediaURL!
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaUrl
            annotations.append(annotation)
    }
   mapView.addAnnotations(annotations)

    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }else{
             pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("clicked!!!!")
        if control == view.rightCalloutAccessoryView{
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle!{
                    let url = URL(string: toOpen)
                    app.open(url!)
            }
        }
    }
    
    func launchAlertView(){
        let name = appDelegate.userDetails[1]
        let alertTitle = "OverWrite Location !!"
        let alertMessage = "Mr." + name + " Do you really want to overWrite your Location ?"
        
        //actions
        let overwriteAction = UIAlertAction(title: "Overwrite",style: .default){(action) in
            let AddNewViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddNewViewController") as! AddNewViewController
            self.present(AddNewViewController, animated: true, completion: nil)
        }
        
        let alert = UIAlertController(title: alertTitle,message: alertMessage,preferredStyle: .alert)
        alert.addAction(overwriteAction)
        alert.addAction(UIAlertAction(title:"Cancel",style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
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
            let alert = UIAlertController(title: "Error",message: "Cannot Download Data",preferredStyle: UIAlertControllerStyle.alert)
            let retry = UIAlertAction(title: "Retry",style: .default ){(action) in
                self.studentData()
            }
            alert.addAction(UIAlertAction(title: "Dismiss" ,style: .default,handler: nil))
            alert.addAction(retry)
            self.present(alert, animated: true, completion: nil)
        }

    }
}



