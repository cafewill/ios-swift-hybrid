//
//  Allo.swift
//

import UIKit;
import Foundation;

class Allo {
    static let CUBE = "cube"
    static let CUBE_DEBUG = true
    static let CUBE_SITE = "https://github.com/cafewill"

    static func i (_ items: Any...) {
        if CUBE_DEBUG {
            Swift.print (CUBE, terminator: " : ")
            for item in items {
                Swift.print (item, terminator: " ")
            }
            Swift.print ()
        }
    }
    
    static func x (_ format: String, _ args: CVarArg...) {
        if CUBE_DEBUG {
            let message = String (format: format, arguments: args)
            NSLog ("%@ : %@", CUBE, message)
        }
    }
}
