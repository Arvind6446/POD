//
//  CarDrConnectionApi.swift
//  test
//
//  Created by Arvind Mehta on 07/04/23.
//

import Foundation
import VoyoAPI


public class  CarDrConnectionApi{
    
    
    
    
 
   public static let carDrApi = CarDrConnectionApi()
    
    private let apiManager = CDAPI.init().apiManager
   private var cdUser =  CDUser.init()
    private var cdDevice: CDDevice? = nil
    var secondsRemaining = 90
   public var cdCallBack:CDCallback? = nil
    var isScanProRunning = false
    
    init() {
        
    }
    
    
    public func disconnetOBD(){
        if(cdDevice?.cdDevice != nil){
            apiManager.refreshOBDDataCache((cdDevice?.cdDevice!.deviceSerial)! )
            apiManager.removeNotifyTarget(self)
            apiManager.getUserAccountsManager().logoutAccount()
           
           
        }
    }
    
    public  func connectOBD(userName:String,password:String) {
        var status = false
        apiManager.getUserAccountsManager().loginToAccount(userName,password , false) { [self] (user,error)->() in
            let timer =   Timer.scheduledTimer(withTimeInterval: 150.0, repeats: false) {_ in
                if(!status){
                cdUser.message = "Device not found or unable to connect please check bluetooth connection"
                cdUser.status = false
                cdCallBack?.getCDDevice(user: cdUser)
                    apiManager.getUserAccountsManager().restoreCurrentAccount { user, error in
                        print(user)
                        
                        
                    }
                    disconnetOBD()
                }
                
                
            }
            
            switch error {
            case .Success:
                let tokenParts = user!.authToken.map { data in String(format: "%02x", data) }
                let tkn = tokenParts.joined()
                cdUser.token = tkn
                
                isScanProRunning = false
               
                DispatchQueue.main.async {
                    user?.addNotifyTarget(self, closure: {
                        cdDevice =  CDDevice.init(cdDevice: user?.currentDevice)
                        if(((cdDevice?.cdDevice?.isConnected)) != nil){
                            if(status){
                                return
                            }
                            status = true
                            self.cdDevice?.cdDevice?.doorControls.autoKeyEnabled = false
                            if(cdCallBack != nil){
                                timer.invalidate()
                                cdUser.status = true
                                cdUser.loggedIn = true
                                cdCallBack?.getCDDevice(user: cdUser)
                                scanOBD()
                            }
                        }

                    })
                }
               
               

            case .ErrorWithDetail(_):
                isScanProRunning = false
                cdUser.message = error.description
                cdUser.status = false
                if(cdCallBack != nil){
                    timer.invalidate()
                    cdUser.status = false
                    cdUser.loggedIn = false
                cdCallBack?.getCDDevice(user: cdUser)
                }
              
                
            case .NoConnection:
                cdUser.message = error.description
                isScanProRunning = false
                cdUser.status = false
                if(cdCallBack != nil){
                    timer.invalidate()
                    cdUser.status = false
                    cdUser.loggedIn = false
                cdCallBack?.getCDDevice(user: cdUser)
                }
               
            case .InvalidParameter(_):
                cdUser.message = error.description
                isScanProRunning = false
                cdUser.status = false
                if(cdCallBack != nil){
                    timer.invalidate()
                    cdUser.status = false
                    cdUser.loggedIn = false
                cdCallBack?.getCDDevice(user: cdUser)
                }
                
            case .NegativeSuccess:
                cdUser.message = error.description
                isScanProRunning = false
                cdUser.status = false
                if(cdCallBack != nil){
                    timer.invalidate()
                    cdUser.status = false
                    cdUser.loggedIn = false
                cdCallBack?.getCDDevice(user: cdUser)
                }
              
            case .NoAuthToken:
                cdUser.message = error.description
                isScanProRunning = false
                cdUser.status = false
                if(cdCallBack != nil){
                    timer.invalidate()
                    cdUser.status = false
                    cdUser.loggedIn = false
                cdCallBack?.getCDDevice(user: cdUser)
                }
               
            case .AccountNotLoggedIn:
                cdUser.message = error.description
                isScanProRunning = false
                cdUser.status = false
                if(cdCallBack != nil){
                    timer.invalidate()
                    cdUser.status = false
                    cdUser.loggedIn = false
                cdCallBack?.getCDDevice(user: cdUser)
                }
                
            }

        }
    }
    
    fileprivate func scanOBD() {
        //Get all data subscrition
        if cdDevice != nil{
           
            secondsRemaining = 90
           
            let data = apiManager.getPreviousScans(cdDevice?.cdDevice?.deviceSerial ?? "")
            let vscans = apiManager.getPreviousScansByVehicle(cdDevice?.cdDevice?.deviceSerial ?? "")
           
            for item in data{
              
                apiManager.deleteScan(item, self.cdUser.token, cdDevice?.cdDevice?.deviceSerial ?? "") { (sp, error) in
                   
                }
            }
            for item in vscans{
                print(item.key)
                print(item.value)
                for it in item.value{
                    apiManager.deleteScan(it, self.cdUser.token, cdDevice?.cdDevice?.deviceSerial ?? "") { (sp, error) in
                       
                        
                    }
                }
                
            }
            DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
                    if self.secondsRemaining > 0 {
                        print ("\(self.secondsRemaining) seconds")
                        self.secondsRemaining -= 1
                    } else {
                        Timer.invalidate()
                       
                        if(self.cdDevice != nil){
                             
                            if(!self.isScanProRunning){
                                self.ActivateScanProCall()
                                }
                            }
                        }
                    }
                }
        }else{
            if(cdCallBack != nil){
                cdUser.message = "Unable to get device object"
                cdUser.status = false
                cdCallBack?.scanError(user: cdUser)
                disconnetOBD()
            }
        }
    }
    
    
    fileprivate func ActivateScanProCall() {
       
        isScanProRunning = true
        self.apiManager.activateScanPro(cdUser.token, self.cdDevice?.cdDevice?.deviceSerial ?? "")
        { [self] (sp: ScanPro?, error ) in
            let cdResponse = CDDeviceResponse()
            
            if (sp != nil){
                cdResponse.vin = sp!.vin ?? ""
              
               
             
               var strArr = [String]()
                var cdScanResponse = [CDScanResponse]()
                strArr.removeAll()
                
               
               
                for  objSP in sp!.controllerList{
                    
                    for dtcVar in objSP.dtcList{
                        let scanResponse = CDScanResponse()
                          if(!strArr.contains(dtcVar.dtc_name ?? "")){
                              
                            var myNewString = ""
                            if(dtcVar.short_description != nil){
                                 myNewString = dtcVar.short_description!.replacingOccurrences(of: "\"", with: "")
                              print(myNewString)
                            }
                              strArr.append(dtcVar.dtc_name ?? "")
                              scanResponse.dtcDesc = myNewString
                              scanResponse.dtcCode = dtcVar.dtc_name ?? ""
                        if (dtcVar.active == true){
                            scanResponse.dtcStatus = "Active"
                        }else if (dtcVar.pending == true){
                            scanResponse.dtcStatus = "Pending"
                        }else{
                            scanResponse.dtcStatus = "Store"
                        }
                        cdScanResponse.append(scanResponse)
                              cdResponse.cdScanResponse = cdScanResponse
                       
                     }
                  }
                    
                    if(cdCallBack != nil)
                    {
                            cdUser.message = "Success"
                            cdUser.status = true
                            cdCallBack?.scanResponse(user: cdUser, cdscanResponse: cdResponse)
                    }
                    
                }
            }else{
                if(cdCallBack != nil)
                {
                    cdUser.message = error.localizedDescription
                    cdUser.status = false
                    cdCallBack?.scanError(user: cdUser)
                }
            }
        }
    }
}
