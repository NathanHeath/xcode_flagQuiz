//
//  ViewController.swift
//  FlagQuiz2
//
//  Created by Nathan Heath on 6/12/15.
//  Copyright (c) 2015 Sports Management Prototypes. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController, ModelDelegate {
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet var segmentedControls: [UISegmentedControl]!
    
    private var model: Model!
    private let correctColor = UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)
    private let incorrectColor = UIColor.redColor()
    private var quizCountries: [String]! = nil
    private var enabledCountries: [String]! = nil
    private var correctAnswer: String! = nil
    private var correctGuesses = 0
    private var totalGuesses = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        model = Model(delegate: self)
        settingsChanged()
    }
    
    func settingsChanged() {
        enabledCountries = model.enabledRegionCountries
        resetQuiz()
    }
    
    func resetQuiz() {
        quizCountries = model.newQuizCountries()
        correctGuesses = 0
        totalGuesses = 0
        
        for i in 0 ..< segmentedControls.count {
            segmentedControls[i].hidden = (i < model.numberOfGuesses / 2) ? false : true
        }
        
        nextQuestion()
    }
    
    func nextQuestion() {
        questionNumberLabel.text = String(format: "Question %1$d of %2$d", (correctGuesses + 1), model.numberOfQuestions)
        answerLabel.text = ""
        correctAnswer = quizCountries.removeAtIndex(0)//pop the next country off the array
        flagImageView.image = UIImage(named: correctAnswer)
        
        // --set up burrons--
        
        //get rid of old buttons
        for segmentedControl in segmentedControls {
            segmentedControl.enabled = true
            segmentedControl.removeAllSegments()
        }
        
        enabledCountries.shuffle()
        var i = 0
        
        //fill up the new buttons
        for seg in segmentedControls {
            if !seg.hidden {
                var segIndex = 0
                while segIndex < 2 {
                    if i < enabledCountries.count && correctAnswer != enabledCountries[i] {
                        seg.insertSegmentWithTitle(countryFromFilename(enabledCountries[i]),
                            atIndex: segIndex, animated: false)
                        ++segIndex
                    }
                    ++i
                }//end while
            }
        }//end for
        
        //put the name of the flag into the buttons at a random place
        let randomRow = Int(arc4random_uniform(UInt32(model.numberOfGuesses / 2)))
        let randomIndexInRow = Int(arc4random_uniform(UInt32(2)))
        segmentedControls[randomRow].removeSegmentAtIndex(randomIndexInRow, animated: false) //take one out at random
        segmentedControls[randomRow].insertSegmentWithTitle(countryFromFilename(correctAnswer), atIndex: randomIndexInRow, animated: false)
    }//end nextQuestion
    
    func countryFromFilename(filename: String) -> String {
        var name = filename.componentsSeparatedByString("-")[1]
        let length: Int = count(name)
        name = (name as NSString).substringToIndex(length - 4)//*.png - .png
        let components = name.componentsSeparatedByString("_")
        return join(" ", components)
    }

    @IBAction func submitGuess(sender: UISegmentedControl) {
        let guess = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)
        let correct = countryFromFilename(correctAnswer)
        ++totalGuesses
        
        if guess != correct {
            sender.setEnabled(false, forSegmentAtIndex: sender.selectedSegmentIndex)
            answerLabel.textColor = incorrectColor
            answerLabel.text = "Incorrect"
            answerLabel.alpha = 1.0
            UIView.animateWithDuration(1.0, animations: {self.answerLabel.alpha = 0.0})
            shakeFlag()
        } else {
            answerLabel.textColor = correctColor
            answerLabel.text = guess! + "!"
            answerLabel.alpha = 1.0
            ++correctGuesses
            
            for seg in segmentedControls {
                seg.enabled = false
            }
            
            if correctGuesses == model.numberOfQuestions {
                displayQuizREsults()
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)),
                    dispatch_get_main_queue(), {self.nextQuestion()})
            }
        }
    }//end submitGuess
    
    func shakeFlag() {
        UIView.animateWithDuration(0.1, animations: {self.flagImageView.frame.origin.x += 16})
        UIView.animateWithDuration(0.1, delay:0.1, options: nil, animations: {self.flagImageView.frame.origin.x -= 32}, completion: nil)
        UIView.animateWithDuration(0.1, delay:0.2, options: nil, animations: {self.flagImageView.frame.origin.x += 32}, completion: nil)
        UIView.animateWithDuration(0.1, delay:0.3, options: nil, animations: {self.flagImageView.frame.origin.x -= 32}, completion: nil)
        UIView.animateWithDuration(0.1, delay:0.4, options: nil, animations: {self.flagImageView.frame.origin.x += 16}, completion: nil)
    }
    
    func displayQuizREsults() {
        let percentString = NSNumberFormatter.localizedStringFromNumber(Double(correctGuesses) / Double(totalGuesses), numberStyle: NSNumberFormatterStyle.PercentStyle)
        
        let alertController = UIAlertController(title: "Quiz Results", message: String(format: "%1$i guesses, %2$@ correct", totalGuesses, percentString), preferredStyle: UIAlertControllerStyle.Alert)
        let newQuizAction = UIAlertAction(title: "New Quiz", style: UIAlertActionStyle.Default, handler: {(action) in self.resetQuiz()})
        alertController.addAction(newQuizAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSettings" {
            let controller = segue.destinationViewController as! SettingsViewController
            controller.model = model
        }
    }
    


}

extension Array {
    mutating func shuffle() {
        for first in stride(from: self.count - 1, through: 1, by: -1) {
            let second = Int(arc4random_uniform(UInt32(first + 1)))
            swap(&self[first], &self[second])
        }
    }
}

