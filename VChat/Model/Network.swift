//
//  Network.swift
//  VChat
//
//  Created by Hesham Salama on 7/8/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import Foundation

class Network {
    
    static func getDataFromURLAsString(url: URL, timeout: TimeInterval, completionHandler: @escaping (String?) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: sessionConfig)
        session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                completionHandler(nil)
                return
            }
            if let data = data, let content = String(data: data, encoding: String.Encoding.utf8) {
                completionHandler(content)
            } else {
                print("No data from url: \(url.absoluteString)")
                completionHandler(nil)
            }
        }
    }
}
