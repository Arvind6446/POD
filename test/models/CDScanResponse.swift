//
//  CDScanResponse.swift
//  test
//
//  Created by Arvind Mehta on 07/04/23.
//

import Foundation

public class CDScanResponse{
   public var dtcCode = ""
   public var dtcDesc  = ""
   public var dtcStatus = ""
}
public class CDDeviceResponse{
   public var vin = ""
   public var cdScanResponse:[CDScanResponse]? = nil
}
