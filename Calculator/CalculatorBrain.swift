//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Богдан Костюченко on 16.09.16.
//  Copyright © 2016 Bogdan Kostyuchenko. All rights reserved.
//

import Foundation


class CalculatorBrain {
    private var accumulator = 0.0
    var result: Double{
        get{
            return accumulator
        }
    }
    
    private var currentPrecedence = Int.max
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        descriptionAccumulator = formatter.string(for: accumulator) ?? ""
    }
    
    //Словарь с всевозможным набором команд для разных кнопок
    private var operations: Dictionary<String, Operation> = [
        //Простейшие математические операции
        "±": Operation.UnaryOperation({-$0}, {"-" + $0}),
        "%": Operation.UnaryOperation({$0*0.01}, {$0 + "*100%"}),
        "-": Operation.BinaryOperation({$0-$1}, {$0 + "-" + $1}, 0), //(op1: Double, op2: Double)->Double) in return op1-op2
        "+": Operation.BinaryOperation({$0+$1}, {$0 + "+" + $1}, 0),
        "×": Operation.BinaryOperation({$0*$1}, {$0 + "×" + $1}, 1),
        "÷": Operation.BinaryOperation({$0/$1}, {$0 + "÷" + $1}, 1),
        "=": Operation.Equals,
        //Математические операции
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "√": Operation.UnaryOperation(sqrt,{"√(" + $0 + ")"}),
        "x²": Operation.UnaryOperation({pow($0,2)}, {"(" + $0 + ")²"}),
        "xʸ": Operation.BinaryOperation({pow($0,$1)}, {"(" + $0 + ")^" + $1 },2),
        "ln": Operation.UnaryOperation(log, {"ln(" + $0 + ")"}),
        "rand": Operation.NullaryOperation(drand48, "rand()"),
        //Тригонометрические операции
        "cos": Operation.UnaryOperation(cos, {"cos(" + $0 + ")"}),
        "cos⁻¹": Operation.UnaryOperation(acos, {"cos(" + $0 + ")⁻¹"}),
        "sin": Operation.UnaryOperation(sin, {"sin(" + $0 + ")"}),
        "sin⁻¹": Operation.UnaryOperation(asin, {"sin(" + $0 + ")⁻¹"}),
        "tg": Operation.UnaryOperation(tan, {"tg(" + $0 + ")"}),
        "tg⁻¹": Operation.UnaryOperation(atan, {"tg(" + $0 + ")⁻¹"})
    ]
    
    private enum Operation{
        case NullaryOperation(() -> Double,String)
        case Constant(Double)
        case UnaryOperation((Double) -> Double,(String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Int)
        case Equals
    }
    
    //Тут выполняются все вычисления(Определяется тип задачи(Binary, Unary, Constant, Equals))
    func performOperation(symbol: String){
        if let operation = operations[symbol]{
            switch operation {
            case .NullaryOperation(let function, let descriptionValue):
                accumulator = function()
                descriptionAccumulator = descriptionValue
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation(let function, let descriptionFunction, let precedence):
                executeBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryOperation: function, firstOperand: accumulator,
                                                     descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .Equals:
                executeBinaryOperation()
            }
        }
    }
    
    
    private func executeBinaryOperation(){
        
        if pending != nil{
            accumulator = pending!.binaryOperation(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    
    func clear() {
        accumulator = 0.0
        pending = nil
        descriptionAccumulator = " "
        currentPrecedence = Int.max
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryOperation: (Double, Double) ->Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
}
class CalculatorFormatter: NumberFormatter {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        self.locale = NSLocale.current
        self.numberStyle = .decimal
        self.maximumFractionDigits = 6
        self.notANumberSymbol = "Error"
        self.groupingSeparator = " "
        
    }
}

let formatter = CalculatorFormatter()

