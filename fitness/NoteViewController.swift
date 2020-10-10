//
//  NoteViewController.swift
//  fitness
//
//  Created by zoehor on 2020/8/18.
//  Copyright © 2020 zoehor. All rights reserved.
//

import UIKit


class NoteViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var setLabel: UILabel!
    @IBOutlet var timesLabel: UILabel!
    @IBOutlet var weightsLabel: UILabel!
    //@IBOutlet var noteLabel: UITextView!

    public var noteTitle: String = ""
    public var setnum: String = ""
    public var timesnum: String = ""
    public var weightsnum: String = ""
    
    //public var note: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = noteTitle
        setLabel.text=setnum
        timesLabel.text=timesnum
        weightsLabel.text=weightsnum
        //noteLabel.text = note
        
    }


}
