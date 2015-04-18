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
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnarayOperation(let symbol, _):
                    return "\(symbol)"
                case .BinaryOperation(let symbol, _):
                    return "\(symbol)"
                }
            }
        }
    }
    
    private var opStack = Array<Op>()
    
    private var knownOperations = Dictionary<String, Op>()
    
    init() {
        // 'teach' our brain about the oppertions it will be asked to perform
        func learnOp(op :Op) {
            knownOperations[op.description] = op
        }
        
        // The characters below are unicode and where placed using the
        // the character selector, the - and + are *not* from the keyboard!
        learnOp(Op.BinaryOperation("+", { $0 + $1 }))
        learnOp(Op.BinaryOperation("−", { $1 - $0 }))
        learnOp(Op.BinaryOperation("×", { $0 * $1 }))
        learnOp(Op.BinaryOperation("÷", { $1 / $0 }))
        learnOp(Op.UnarayOperation("√", { sqrt($0) }))
        learnOp(Op.UnarayOperation("cos", { cos($0) }))
        learnOp(Op.UnarayOperation("sin", { sin($0) }))
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
            }
        }
        
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluateRecursivley(opStack)
        
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func perforOperation(symbol: String) -> Double? {
        if let operation = knownOperations[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
}