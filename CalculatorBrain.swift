//
//  CalculatorBrain.swift
//  SwiftCalc
//
//  Created by Mark Keightley on 17/04/2015.
//  Copyright (c) 2015 Hyperion Systems. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: Printable {
        case Operand(Double)
        case UnarayOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Constant(String)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnarayOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Constant(let symbol):
                    return symbol
                case .Variable(let name):
                    return name
                }
            }
        }
    }
    
    private var opStack = Array<Op>()
    private var knownOperations = Dictionary<String, Op>()
    private var knownConstants = Dictionary<String, Double>()
    
    var description: String {
        get {
            return describeStack()
        }
    }
    
    var variableNames = Dictionary<String,Double>()
    
    var debug = false
    
    init() {
        // 'teach' our brain about the oppertions it will be asked to perform
        func learnOp(op :Op) {
            knownOperations[op.description] = op
        }
        
        // I have to define constants here in knownConstants dictionary
        // this seems a bit...clunky, but it works
        knownConstants["∏"] = M_PI
        
        // The characters below are unicode and where placed using the
        // the character selector, the - and + are *not* from the keyboard!
        learnOp(Op.BinaryOperation("+", { $0 + $1 }))
        learnOp(Op.BinaryOperation("−", { $1 - $0 }))
        learnOp(Op.BinaryOperation("×", { $0 * $1 }))
        learnOp(Op.BinaryOperation("÷", { $1 / $0 }))
        learnOp(Op.UnarayOperation("√", { sqrt($0) }))
        learnOp(Op.UnarayOperation("cos", { cos($0) }))
        learnOp(Op.UnarayOperation("sin", { sin($0) }))
        learnOp(Op.UnarayOperation("+/−", {
            signbit($0) == 0 ? copysign($0, -1) : copysign($0, 1)
        }))
        learnOp(Op.Constant("∏"))
    }
    
    private func evaluateRecursivley(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            // Make mutable copy of our immutalbe function argument!
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            // Process our stack by switching on our Op type, that holds the 
            // closures which perform the actual opperations
            switch op {
            case .Operand(let opreand):
                return (opreand, remainingOps)
            case .UnarayOperation(_, let operation):
                let operandEvaluation = evaluateRecursivley(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluateRecursivley(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluateRecursivley(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2),op2Evaluation.remainingOps)
                    }
                }
            case .Constant(let symbol):
                return (knownConstants[symbol], remainingOps)
            case .Variable(let name):
                return (variableNames[name], remainingOps)
            }
        }
        
        return (nil, ops)
    }
    
    private func describeTopOfStack(depth: Int, inout stack: [Op]) -> String {
        var currentDescription = "" // Our return value if the stack is empty
        var currentDepth = depth + 1
        
        if !stack.isEmpty {
            let op = stack.removeLast()
            
            switch op {
            case .Operand(let operand):
                var textValue = "\(operand)"
                // Remove trailing .0 if present
                if var uselessSufix = textValue.rangeOfString(".0") {
                    textValue.removeRange(uselessSufix)
                }
                currentDescription += textValue
            case .UnarayOperation(let uOperator, _):
                // Unarays should look like this 'function_name(value)'
                let operand = describeTopOfStack(currentDepth, stack: &stack)
                // No need to check for depth, all functions have there operands
                // surounded by parentheies
                currentDescription = uOperator + "(" + operand + ")"
            case .BinaryOperation(let bOperator, _):
                // Binarys should look like this 'operand1 operator operand2'
                let operand1 = describeTopOfStack(currentDepth, stack: &stack)
                let operand2 = describeTopOfStack(currentDepth, stack: &stack)
                
                // Need to worry about the order of operands for subtract
                // and multiplication operators
                if bOperator == "−" || bOperator == "÷" {
                    currentDescription += "\(operand2)" + bOperator + "\(operand1)"
                }
                else {
                    currentDescription += "\(operand1)" + bOperator + "\(operand2)"
                }
                // Add parentheies as needed
                if currentDepth > 1 {
                    currentDescription = "(" + currentDescription + ")"
                }
            case .Constant(let symbol):
                currentDescription += symbol
            case .Variable(let name):
                currentDescription += name
            }
        }
        
        return currentDescription
    }
    
    private func describeStack() -> String {
        var stackDescription = ""
        // Make a copy of the stack, since we consume it
        var workingStack = opStack
        
        do {
            // The slighty odd looking order here is because we need the
            // resulting string to read left to right
            stackDescription = describeTopOfStack(0, stack: &workingStack) + stackDescription
        
            if workingStack.count > 0 {
                stackDescription = ", " + stackDescription
            }
        } while workingStack.count > 0
        
        return stackDescription
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluateRecursivley(opStack)
        
        if debug {
            println("\(opStack) = \(result) with \(remainder) left over")
        }
        
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        
        return evaluate()
    }
    
    func pushOperand(operand: String) -> Double? {
        opStack.append(Op.Variable(operand))
        
        return evaluate()
    }
    
    func pushConstant(symbol: String) -> Double? {
        opStack.append(Op.Constant(symbol))
        return knownConstants[symbol]
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOperations[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
    
    func clearStack() {
        // Very simple this! (at the moment anyway)
        opStack.removeAll(keepCapacity: true)
    }
}