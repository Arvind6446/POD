//
//  API.swift
//  test
//
//  Created by Arvind Mehta on 07/04/23.
//

import Foundation
import VoyoAPI

struct CDAPI {
    let  apiManager = VoyoAPIManager(Environment.Prod).getAPI()
   
}
