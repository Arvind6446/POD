//
//  CDCallback.swift
//  test
//
//  Created by Arvind Mehta on 07/04/23.
//

import Foundation
public protocol CDCallback{
   
    func getCDDevice(user:CDUser)
    func getScanedData(user:CDUser)
    func scanError(user:CDUser)
    func scanStart()
    func scanResponse(user:CDUser,cdscanResponse:CDDeviceResponse)
    
}
