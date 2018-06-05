import Foundation

func callAPI(withJSONObject jsonPayload: Dictionary<String, Any>, Completion block: @escaping (Bool, [String: Any]) -> ()) {
    guard let url = URL(string: "http://www.musuapp.com/API/API.php") else {
        fatalError("Could not create URL structure from API URL.")
    }

    let session = URLSession.shared

    var request = URLRequest(url: url)

    do {
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: jsonPayload, options: .prettyPrinted)
    } catch let error {
        print("callAPI(): \(error.localizedDescription)")
    }

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        guard let data = data else {
            print("callAPI(): Data is nil after session.dataTask() call.")
            return
        }

        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                let successful = jsonResponse["success"] as? Bool ?? false
                
                block(successful, jsonResponse)
            }
        } catch let error {
            print("callAPI(): \(error.localizedDescription)")
        }
    })
    
    task.resume()
}
