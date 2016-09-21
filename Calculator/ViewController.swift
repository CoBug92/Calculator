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
    
    
    //MARK: Value
    private var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    private var displayValue: Double? {
        get {
            if let text = display.text,
                let value = NumberFormatter().number(from: text)?.doubleValue {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = NumberFormatter().string(from: NSNumber(value))
                history.text = brain.description + (brain.isPartialResult ? " …" : " =")
            } else {
                display.text = " "
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
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            //----- Уничтожаем лидирующие нули -----------------
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")){ return }
            if (digit !=  ".") && ((display.text == "0") || (display.text == "-0"))
            { display.text = digit ; return }
            //--------------------------------------------------
            
            if (digit != ".") || (textCurrentlyInDisplay.range(of: ".") == nil) {
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
}
