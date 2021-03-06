//
//  ViewController.swift
//  Calculator
//
//  Created by Богдан Костюченко on 16.09.16.
//  Copyright © 2016 Bogdan Kostyuchenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    //Mark: Properties
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var point: UIButton!{
        didSet {
            point.setTitle(decimalSeparator, for: UIControlState())
        }
    }
    
    
    //MARK: Value
    fileprivate var userIsInTheMiddleOfTyping = false
    let decimalSeparator = formatter.decimalSeparator ?? "."
    private var brain = CalculatorBrain()
    private var displayValue: Double? {
        get {
            if let text = display.text,
                let value = formatter.number(from:text)?.doubleValue {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = formatter.string(for: value)
                history.text = brain.description + (brain.isPartialResult ? " …" : " =")
            } else {
                display.text = "0"
                history.text = " "
                userIsInTheMiddleOfTyping = false
            }
        }
    }
    
    
    //Mark: Actions
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if let value = displayValue{
                brain.setOperand(operand: value)
            }
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle{
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result
    }
    
    @IBAction private func touchDigit(sender: UIButton){
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            //----- Уничтожаем лидирующие нули -----------------
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")){ return }
            if (digit !=  decimalSeparator) && ((display.text == "0") || (display.text == "-0"))
            { display.text = digit ; return }
            //--------------------------------------------------
            
            if (digit != decimalSeparator) || (textCurrentlyInDisplay.range(of: decimalSeparator) == nil) {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction func backspace(sender: UIButton) {
        if userIsInTheMiddleOfTyping  {
            display.text!.remove(at: display.text!.endIndex)
        }
        if display.text!.isEmpty {
            userIsInTheMiddleOfTyping  = false
            displayValue = brain.result
        }
    }
    @IBAction func plusMinus(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping  {
            if (display.text!.range(of: "-") != nil) {
                display.text = String((display.text!).characters.dropFirst())
            } else {
                display.text = "-" + display.text!
            }
        } else {
            performOperation(sender: sender)
        }
    }
    
    @IBAction func ClearAll(_ sender: UIButton) {
        brain.clear()
        displayValue = nil
    }
    
    
}
