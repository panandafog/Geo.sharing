//
//  ConnectionService.swift
//  geo
//
//  Created by Andrey on 18.12.2022.
//

import CoreLocation

enum ConnectionService {
    
    static func sendLocation(_ location: CLLocation) {
        sendLocation(LocationModel(from: location))
    }
    
    static func sendLocation(_ location: LocationModel) {
        
        var components = URLComponents()
        components.scheme = "http"
        components.host = "94.19.109.140"
        components.port = 5555
        components.path = "/save_geo"
        
        guard let url = components.url else {
            print("url error")
            return
        }
        
        print(url.absoluteString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(location)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {                                                               // check for fundamental networking error
                print("error", error ?? URLError(.badServerResponse))
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            print(String(data: data, encoding: .utf8))
        }.resume()
        
    }
}
