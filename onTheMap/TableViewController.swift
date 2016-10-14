//
//  TableViewController.swift
//  onTheMap
//
//  Created by Arjun Baru on 02/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import UIKit


class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
     appDelegate =  UIApplication.shared.delegate as! AppDelegate!
    }
    override func viewWillAppear(_ animated: Bool) {
        self.reach()
        StudentData()
     self.tableView.reloadData()
    }

    var appDelegate: AppDelegate!
    
    @IBAction func pinAction(_ sender: AnyObject) {
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
    
    
    @IBAction func logoutButton(_ sender: AnyObject) {
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
    
    
    func StudentData(){
              
        parseClient.sharedInstance().codeForStudentData(){(result,network,error) in
            if error != nil{
                print("error found phir downloading")
                return
            }
            if network != true{
                performUIUpdatesOnMain {
                    let alert = UIAlertController(title: "Error",message: "Cannot Download Data",preferredStyle: UIAlertControllerStyle.alert)
                    let retry = UIAlertAction(title: "Retry",style: .default ){(action) in
                        self.StudentData()
                    }
                    alert.addAction(retry)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            guard let recievedResult = result else{
                print("unable to Parse")
                return
            }
            print("recieved result is \(recievedResult)")
            if !StudentInformation.studentData.isEmpty{
                StudentInformation.studentData.removeAll()
            }
            
            
               for s in recievedResult{
                
                    if(s["latitude"] != nil){
                        StudentInformation.studentData.append(StudentInformation(dictionary: s))
                    
                }
                //arranging student data
                 StudentInformation.studentData = StudentInformation.studentData.sorted() {$0.updatedAt.compare($1.updatedAt as Date) == ComparisonResult.orderedDescending}
            }
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return StudentInformation.studentData.count
    }
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapTableView")!
    let mapObject = StudentInformation.studentData[(indexPath as IndexPath).row]
    
     cell.textLabel?.text = "\(mapObject.firstName) \(mapObject.lastName)"
    cell.detailTextLabel?.text = (mapObject.mediaURL!)
    cell.imageView?.image = #imageLiteral(resourceName: "Pin")
    return cell
    }
    
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        if let cell = tableView.cellForRow(at: indexPath){
            if let toOpen = cell.detailTextLabel?.text{
                
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
            let AddNewViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddNewViewController")
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
  
    
    
    
}
