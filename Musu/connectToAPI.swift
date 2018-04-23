//
//  connectToAPI.swift
//  Musu
//
//  Created by Richard Zarth on 4/19/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import Foundation

func connectToAPI(withJSON: Dictionary<String, String>, Completion block: @escaping ([String: Any]) -> ()) {

    let parameters = withJSON

    let url = URL(string: "http://www.musuapp.com/API/API.php")!

    let session = URLSession.shared

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
    } catch let error {
        print(error.localizedDescription)
    }

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
        guard error == nil else {
            return
        }

        guard let data = data else {
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                block(json)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    })
    
    task.resume()
}
