//
//  ViewController.swift
//  SwiftCalc
//
//  Created by Mark Keightley on 12/04/2015.
//  Copyright (c) 2015 Hyperion Systems. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)";
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBOutlet weak var historyDisplay: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        }
        else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func enter() {
        ////TODO
        // move to model maybe?
        updateHistoryDisplay(display.text!)
        
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        }
        else {
            ////TODO
            // This is an error condtion, we need to make displayValue an
            // optional so I can handle this error correctly
            displayValue = 0
        }
        
        userIsInTheMiddleOfTypingANumber = false
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.perforOperation(operation) {
                displayValue = result
            }
            else {
                ////TODO
                // This is an error condtion, we need to make displayValue an
                // optional so I can handle this error correctly
                displayValue = 0
            }

            
            ////TODO
            // move to model maybe
            updateHistoryDisplay(operation)
        }
    }
    
    @IBAction func decimalPoint() {
        // Figure out if we have a decimal point already
        // Not going to use a flag that I set here, as the
        // result of an operation can also add a decimal place
        if display.text!.rangeOfString(".") == nil {
            display.text = display.text! + "."
            userIsInTheMiddleOfTypingANumber = true
        }
        
        updateHistoryDisplay(".")
    }
    
    @IBAction func performCalculatorAction(sender: UIButton) {
        // Peform actions which affect the state of the calculator it's self
        // These are nothing to do with actual calculations, e.g clearing displa
        // reseting etc.
        let action = sender.currentTitle!
        
        switch action {
            case "C": clearCalc()
            case "bksp": clearLastDigit()
            default: break
        }
    }
    
    func pushToOperandStack(value: Double) {
        display.text = "\(value)"
        enter()
    }
    
    ////TODO
    // These three functions need to be moved to and updated to work with the model
    func updateHistoryDisplay(item: String) {
        historyDisplay.text = historyDisplay.text! + " \(item)"
    }
    
    func clearCalc() {
        // Reset to launch state
        display.text = "0"
        historyDisplay.text = "History:"
        //operandStack.removeAll(keepCapacity: true)
        userIsInTheMiddleOfTypingANumber = false
    }
    
    func clearLastDigit() {
        // Doing a lot of work with display.text so cache it locally
        // It can be a constant since the changes are all made to
        // display.text, not the local copy.
        /*
        let localDisplayText = display.text!
        
        // Only allow deletes if, I've entered this number (it's not
        // the result of calcuation)
        if userIsInTheMiddleOfTypingANumber {
            // If this is this the last digit, make it 0 instead of deleting it
            if localDisplayText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 1 {
                display.text = "0"
                // To avoid problems with leading 0's we need to come out of
                // entry mode now
                userIsInTheMiddleOfTypingANumber = false
            }
            else {
                // Delete last digit
                display.text = localDisplayText.substringToIndex(localDisplayText.endIndex.predecessor())
            }
        }*/
    }
}