//
//  ViewController.swift
//  Geofence
//
//  Created by Mind on 03/02/18.
//  Copyright © 2018 Mindinventory. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txtLat: UITextField!
    @IBOutlet weak var txtLong: UITextField!
    @IBOutlet weak var txtRange: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtMsg: UITextField!
    @IBOutlet weak var btnAddnearBy: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    @IBAction func btnAddNearByClk()
    {
        
        let lati = [23.057582,23.057598,23.057347,23.057361,23.057391,23.059445,23.059445,23.052384,23.061001,23.062675,23.065157,23.065206,23.064434]
        let longg = [72.534458,72.534541,72.534482,72.534176,72.534724,72.534302,72.534302,72.533718,72.537140,72.537929,72.539007,72.538052,72.537143]
        
        let Titlls = ["MI","MI Prking","MI Exit 1","MI Mian Exit","MI okffice","Turn 1 Triangle","Turn 2 Way to bhuyangdev","bhuyang","Way one Dubey Turn","C.p","Trun Shaibagh","enter Shaibagh Milk","Home"]
        
        
        let radius = [100.0,50,300,20,30,240,50,100,110,150,170,200,300]
                      
        
        for i in 0..<lati.count
            {
                let geoFance  = (TblGeofence.findOrCreate(dictionary: ["identifier":"\(Date.timeIntervalSinceReferenceDate)"]) as? TblGeofence)!
                geoFance.latitude = lati[i]
                geoFance.longitude = longg[i]
                geoFance.range = radius[i]
                geoFance.title = Titlls[i]
                geoFance.msg = "\(radius[i])"
                
                appDelegate.registerGeoFance(obj: geoFance)
        }
        
        CoreData.sharedInstance.saveContext()
        
    }
    @IBAction func btnAddClk()
    {
        self.view.endEditing(true)
        
        if !(txtLat.text?.validDouble())!
        {
            self.showErrorMsg(str: "Enter Valid latitude")
            return;
        }
        if !(txtLong.text?.validDouble())!
        {
            self.showErrorMsg(str: "Enter Valid Longitude")
            return;
        }
        if !(txtRange.text?.validDouble())!
        {
            self.showErrorMsg(str: "Enter Valid Range")
            return;
        }
        if (txtTitle.text?.isEmpty)!
        {
            self.showErrorMsg(str: "Enter Title")
            return;
        }
        
        if (txtMsg.text?.isEmpty)!
        {
            self.showErrorMsg(str: "Enter Msg")
            return;
        }
        
        let geoFance  = (TblGeofence.findOrCreate(dictionary: ["identifier":"\(Date.timeIntervalSinceReferenceDate)"]) as? TblGeofence)!
        geoFance.latitude = Double(txtLat.text!)!
        geoFance.longitude = Double(txtLong.text!)!
        geoFance.range = Double(txtRange.text!)!
        geoFance.title = txtTitle.text
        geoFance.msg = txtMsg.text
        CoreData.sharedInstance.saveContext()
        
        appDelegate.registerGeoFance(obj: geoFance)
        self.showErrorMsg(str: "Data Added")
        txtLat.text = ""
        txtLong.text = ""
        txtRange.text = ""
        txtTitle.text = ""
        txtMsg.text = ""
        
    }
    
    func showErrorMsg(str:String)
    {
        let alert = UIAlertController(
            title: "Empty",
            message: str,
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (alert) -> Void in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }


}

