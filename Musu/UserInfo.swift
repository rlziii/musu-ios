//
//  UserInfo.swift
//  Musu
//
//  Created by Richard Zarth on 5/13/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import Foundation

func getUserID() -> String {
    guard let userID = UserDefaults.standard.value(forKey: "userID") as? Int
        else {
            fatalError("No userID found in UserDefaults!")
    }
    
    return String(userID)
}

func getToken() -> String {
    let token: String
    
    do {
        let tokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                             account: getUserID(),
                                             accessGroup: KeychainConfiguration.accessGroup)
        
        token = try tokenItem.readPassword()
    } catch {
        fatalError("Error reading token from Keychain - \(error)")
    }
    
    return token
}
