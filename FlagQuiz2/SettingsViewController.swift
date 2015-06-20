//
//  SettingsViewController.swift
//  FlagQuiz2
//
//  Created by Nathan Heath on 6/12/15.
//  Copyright (c) 2015 Sports Management Prototypes. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var guessesSegmentedControl: UISegmentedControl!
    @IBOutlet var switches: [UISwitch]!
    
    var model: Model!
    private var regionNames = ["Africa", "Asia", "Europe", "North_America", "Oceania", "South_America"]
    private let defaultRegionIndex = 3
    
    private var settingsChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guessesSegmentedControl.selectedSegmentIndex = model.numberOfGuesses / 2 - 1
        
        for i in 0 ..< switches.count {
            switches[i].on = model.regions[regionNames[i]]!
        }
    }

    @IBAction func numberOfGuessesChanged(sender: UISegmentedControl) {
        model.setNumberOfGuesses(2 + sender.selectedSegmentIndex * 2)
        settingsChanged = true
    }
    
    @IBAction func switchChanged(sender: UISwitch) {
        for i in 0 ..< switches.count {
            if sender == switches[i] {
                model.toggleRegion(regionNames[i])
                settingsChanged = true
            }
        }
        
        if model.regions.values.array.filter({$0 == true}).count == 0 {
            model.toggleRegion(regionNames[defaultRegionIndex])
            switches[defaultRegionIndex].on = true
            displayErrorDialog()
        }
    }
    
    func displayErrorDialog() {
        let alertController = UIAlertController(title: "At least one region required",
            message: String(format: "Selectiong %0 as the default region", regionNames[defaultRegionIndex]), preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        if settingsChanged {
            model.notifyDelegate()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
