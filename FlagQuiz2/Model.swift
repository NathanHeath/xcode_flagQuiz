//
//  Model.swift
//  FlagQuiz2
//
//  Created by Nathan Heath on 6/12/15.
//  Copyright (c) 2015 Sports Management Prototypes. All rights reserved.
//

import Foundation

protocol ModelDelegate {
    func settingsChanged()
}

class Model {
    private let regionsKey = "FlagQuizKeyRegions"
    private let guessesKey = "FlagQuizKeyGuesses"
    
    private var delegate: ModelDelegate! = nil
    var numberOfGuesses = 4
    
    private var enabledRegions = [
        "Africa" : false,
        "Asia" : false,
        "Europe" : false,
        "North_America" : true,
        "Oceania" : false,
        "South_America" : false
    ]
    
    let numberOfQuestions = 10
    private var allCountries: [String] = []
    private var countriesInEnabledRegions: [String] = []
    
    init (delegate: ModelDelegate) {
        self.delegate = delegate
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let tempGuesses = userDefaults.integerForKey(guessesKey)
        if tempGuesses != 0 {
            numberOfGuesses = tempGuesses
        }
        
        if let tempRegions = userDefaults.dictionaryForKey(regionsKey) {
            self.enabledRegions = tempRegions as! [String : Bool]
        }
        
        //let paths = NSBundle.mainBundle().pathsForResourcesOfType("png", inDirectory: nil) as! [String]
        
        // get a list of all the png files in the app's images group
        let paths = NSBundle.mainBundle().pathsForResourcesOfType(
            "png", inDirectory: nil) as! [String]

        
        for path in paths {
            if !path.lastPathComponent.hasPrefix("AppIcon") {
                allCountries.append(path.lastPathComponent)
            }
        }
        
        regionsChanged()
    }//end init
    
    func regionsChanged() {
        countriesInEnabledRegions.removeAll()
        
        for filename in allCountries {
            let region = filename.componentsSeparatedByString("-")[0]
            
            if enabledRegions[region]! {
                countriesInEnabledRegions.append(filename)
            }
        }
    }//end regionsChanged
    
    var regions: [String : Bool] {
        return enabledRegions
    }
    
    var enabledRegionCountries: [String] {
        return countriesInEnabledRegions
    }
    
    func toggleRegion(name: String) {
        enabledRegions[name] = !(enabledRegions[name]!)//flip it
        NSUserDefaults.standardUserDefaults().setObject(enabledRegions as NSDictionary, forKey: regionsKey)//save it
        NSUserDefaults.standardUserDefaults().synchronize()//commit save
        regionsChanged()//update app
    }
    
    func setNumberOfGuesses(guesses: Int) {
        numberOfGuesses = guesses //set value
        NSUserDefaults.standardUserDefaults().setInteger(numberOfGuesses, forKey: guessesKey)//save it
        NSUserDefaults.standardUserDefaults().synchronize()//commit save
    }
    
    // called by SettingsViewController when settings change
    // to have model notify QuizViewController of the changes
    func notifyDelegate() {
        delegate.settingsChanged()
    }
    
    func newQuizCountries() -> [String] {
        var quizCountries: [String] = []
        
        var flagCounter = 0
        
        //pick 10 countries from the pool of enabled regions
        while flagCounter < numberOfQuestions {
            let randomIndex = Int(arc4random_uniform(UInt32(enabledRegionCountries.count)))//random number less than count
            let filename = enabledRegionCountries[randomIndex]//array element from random number
            
            if quizCountries.filter({$0 == filename}).count == 0 {//see if the country is already in the list
                quizCountries.append(filename)//if it's not in the list yet, add it
                ++flagCounter//move on
            }
            
        }
        
        return quizCountries
    }//end newQuizCountries
    
    
}//end class
