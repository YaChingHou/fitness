//
//  ViewController.swift
//  fitness
//
//  Created by zoehor on 2020/8/13.
//  Copyright © 2020 zoehor. All rights reserved.
//



import FSCalendar
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseCore

class ViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var calendar:FSCalendar!
    @IBOutlet var tableview:UITableView!
    @IBOutlet var label: UILabel!
    
    //stored the date didSelected
    var dateSelected:[String]=[]
    //stored the title as filtering
    var addedtitleStored:[String]=[]
    //stored the data ready to show
    var filteredDataStored:[String]=[]
    //stored all the information downloaded
    var fitnessInformation:Dictionary<String, String> = [:]
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate=self
            
        //將calendar可以做垂直滾動
        calendar.scrollDirection = .vertical
            
        //運用addview讓一個view加到另一個view上
        //view上將了一個view為calender的view
        self.view.addSubview(calendar)
        
        
        //tableview section
        tableview.delegate=self
        tableview.dataSource=self

        ref = Database.database().reference()
        
        //FirebaseApp.configure()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            
        }
        

    }
    
     func calendar (_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        
        let formatter = DateFormatter()
        formatter.dateFormat  = "MM-dd-YYYY"
        let Datestring = formatter.string(from:date)
        
        //stored the date didSelected
        self.dateSelected=[Datestring]
        
        //print("\(Datestring)")
        //print("\(self.dateSelected)")
        
        viewWillAppear(true)
                 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //the date should be selected
        if calendar.selectedDate != nil{
            //print("selected the date")
            
            //let the "filteredDataStored array"
            //to catch the return answer from fetchRecentMsgs()
            self.filteredDataStored=fetchRecentMsgs()
            
            //print("\(addedtitleStored)")
            
            //successful to show the data onto the tableview
            self.tableview.isHidden = false
            self.tableview.reloadData()
            
        }
    }
    
    func fetchRecentMsgs() -> [String] {
        //ordering by startTime
        let refOfcalendar = Database.database().reference().queryOrdered(byChild: "titles")
        refOfcalendar.observeSingleEvent(of: .value, with: {(snapshot) in
            //aim to refresh the array as recall the function again
            self.addedtitleStored=[]
            
            //read multi data
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    self.fitnessInformation = snap.value as! Dictionary<String, String>
                    //let key = snap.key
                    let tempDate = self.fitnessInformation["date"]!
                    
                
                    //filtering the corresponding date to selected date
                    if tempDate == self.dateSelected[0] {
                        let tempTitle = self.fitnessInformation["titles"] as String?
                        self.addedtitleStored.append(tempTitle!)
                    }
                    
                }
            }
        })
        //just return the data selected-date
        return self.addedtitleStored
    }
    
    func deleteMegs(deleteTitle:String){
        //should store the id corresponding to the title we wanted to delete
        //using the id to remove the whole information in the firebase
        var deleteId:[String]=[]

        let ref = Database.database().reference()
        //using queryStarting,becoz the filtering reason are not only just one record
        let reff=ref.queryOrdered(byChild: "date").queryStarting(atValue: self.dateSelected[0])
        reff.observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    let temp = snap.value as! Dictionary<String, String>
                    if temp["titles"] == deleteTitle{
                        deleteId=[temp["id"]!]
                        ref.child(deleteId[0]).removeValue()
                    }
                    
                }
                
            }
        })
    }
    
    @IBAction func didTapNewNote() {
        if let vc = storyboard?.instantiateViewController(identifier: "new") as? DataEntryViewController{
            vc.title = "New Note"
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    }
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedtitleStored.count
       }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = addedtitleStored[indexPath.row]
        return cell
       }
    
    //delete the selected title of the date
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            tableview.beginUpdates()
            //deleteTitle is the variable to store the title we wanted to delete
            let deleteTitle = addedtitleStored.remove(at: indexPath.row)
            //function to delete the data in the datebase
            deleteMegs(deleteTitle: deleteTitle)
            
            // should also delete the title showing on the tableview
            tableview.deleteRows(at:[indexPath], with: UITableView.RowAnimation.fade)
            tableview.endUpdates()
            
            //print("\(self.dateSelected[0])")
            //print("\(deleteTitle)")
            
        }
    }
    
    
}


