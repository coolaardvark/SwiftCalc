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
    @IBOutlet weak var historyDisplay: UILabel!
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)";
            }
            else {
                // Use a space to prevent the display from colapsing down to
                // it's minium size
                display.text = " "
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
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
        displayValue = brain.pushOperand(displayValue!)
        userIsInTheMiddleOfTypingANumber = false
        
        historyDisplay.text = "History: " + brain.description
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)

            historyDisplay.text = "History: " + brain.description
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
    }
    
    
    @IBAction func signChange(sender: UIButton) {
        // This button gets it's own function since it acts differently
        // depending on if the user is entering a number or not
        if userIsInTheMiddleOfTypingANumber {
            // Toggle the sign of the display
            if display.text!.hasPrefix("−") {
                display.text = display.text!.substringFromIndex(display.text!.startIndex.successor())
            }
            else {
                display.text = "−\(display.text!)"
            }
        }
        else {
            // Opperate on the top of the stack, creating a new entry
            // This seems odd to me, but is how RPN calculators seem work
            
            // I pass in the sender button so I can do this!
            operate(sender)
        }
    }
    
    @IBAction func performCalculatorAction(sender: UIButton) {
        // Peform actions which affect the state of the calculator it's self
        // These are nothing to do with actual calculations, e.g clearing display
        // reseting etc.
        let action = sender.currentTitle!
        
        switch action {
            case "C": clearCalc()
            case "bksp": clearLastDigit()
            default: break
        }
    }
    
    @IBAction func enterConstant(sender: UIButton) {
        // Push named constant to stack and display it
        // Since the constant has been pushed we need to finish off out
        // of entry mode
        let symbol = sender.currentTitle!
        if let value = brain.getConstant(symbol) {
            display.text = "\(value)"
        }
        
        enter()
    }
    
    func clearCalc() {
        // Reset to launch state
        brain.clearStack()
        
        display.text = "0"
        historyDisplay.text = "History:"
        userIsInTheMiddleOfTypingANumber = false
    }
    
    func clearLastDigit() {
        // Only allow deletes if, I've entered this number (it's not
        // the result of calcuation)
        
        if userIsInTheMiddleOfTypingANumber && display.text! != "0" {
            // If this is this the last digit, make it 0 instead of deleting it
            if display.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 1 {
                display.text = "0"
                
                // To avoid problems with leading 0's we need to come out of
                // entry mode now
                userIsInTheMiddleOfTypingANumber = false
            }
            else {
                display.text = display.text!.substringToIndex(display.text!.endIndex.predecessor())
            }
        }
    }
}