//
//  EntryViewController.swift
//  fitness
//
//  Created by zoehor on 2020/8/19.
//  Copyright © 2020 zoehor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseCore

class EntryViewController: UIViewController {

    @IBOutlet var titleField: UITextField!
    @IBOutlet var setField: UITextField!
    @IBOutlet var timesField: UITextField!
    @IBOutlet var weightsField: UITextField!

    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //connecting to the firebase
        ref = Database.database().reference()
                
               if FirebaseApp.app() == nil {
                   FirebaseApp.configure()
               }
        
        self.titleField.placeholder = "運動項目"
        self.setField.placeholder = "組數"
        self.timesField.placeholder = "次數"
        self.weightsField.placeholder = "重量"
        
        titleField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        
        
    }
    
    //adding the date to the firebase
    func addtitle(){
        //generating a new key inside artists node
        //and also getting the generated key
        let key = ref.childByAutoId().key
        
    
        //insert the Date to the firebase
        //as adding the fitness title and information
        
        //using the Date() is better than using the NSDate
        let now = Date()
        
        //transform the timestamp
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM-dd-YYYY"
        let dateString = formatter.string(from: now)
        
    
        let fitnessInformation = ["id":key,
                        "titles": titleField.text! as String,
                        "sets": setField.text! as String,"times": timesField.text! as String,"weights": weightsField.text! as String,"date":dateString as String
                        ]
    
        //adding the "fitnessInformation" inside the generated unique key
        ref.child(key!).setValue(fitnessInformation)
    }
    
    
    //as Click Save button will return to the home page and call the "addtitle()"
    @objc func didTapSave() {
        addtitle()
        self.navigationController?.popToRootViewController(animated: true)
    }
}
