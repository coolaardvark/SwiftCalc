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
    var operandStack = Array<Double>()
    
    var debug = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        operandStack.append(displayValue)
        updateHistoryDisplay(display.text!)
        userIsInTheMiddleOfTypingANumber = false
        
        if debug {
            println("Operand stack = \(operandStack)")
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        // The characters below are unicode and where placed using the
        // the character selector, the - and + are *not* from the keyboard!
        switch operation {
            case "+": performBinaryOperation { $0 + $1 }
            case "−": performBinaryOperation { $1 - $0 }
            case "×": performBinaryOperation { $0 * $1 }
            case "÷": performBinaryOperation { $1 / $0 }
            case "√": performUniaryOperation { sqrt($0) }
            case "cos": performUniaryOperation { cos($0) }
            case "sin": performUniaryOperation { sin($0) }
            case "∏": pushToOperandStack(M_PI)
            default: break
        }
        
        updateHistoryDisplay(operation)
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
    
    func performBinaryOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(),operandStack.removeLast())
            enter()
        }
    }
    
    func performUniaryOperation(operation: Double -> Double ) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    func pushToOperandStack(value: Double) {
        display.text = "\(value)"
        enter()
    }
    
    func updateHistoryDisplay(item: String) {
        historyDisplay.text = historyDisplay.text! + " \(item)"
    }
    
    func clearCalc() {
        // Reset to launch state
        display.text = "0"
        historyDisplay.text = "History:"
        operandStack.removeAll(keepCapacity: true)
        userIsInTheMiddleOfTypingANumber = false
    }
    
    func clearLastDigit() {
        // Doing a lot of work with display.text so cache it locally
        // It can be a constant since the changes are all made to
        // display.text, not the local copy.
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
        }
    }
}