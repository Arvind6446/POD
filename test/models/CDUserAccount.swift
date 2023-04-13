//
//  CDUserAccount.swift
//  test
//
//  Created by Arvind Mehta on 07/04/23.
//

import Foundation

protocol CDUserAccount{
    
    var firstName:String { get }
    
    var token:String { get }
    
    var lastName:String { get }
    
    var userName:String { get }
    
    var loggedIn:Bool { get }
    
    var status:Bool? { get }
    
    var message:String { get }
    
    
    
}
