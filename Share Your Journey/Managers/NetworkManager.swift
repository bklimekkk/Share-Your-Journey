//
//  NetworkManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 22/03/2022.
//

import Foundation
import Network

class NetworkManager: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkManager")
    @Published var connected = true
    init (){
        monitor.pathUpdateHandler = {path in
            DispatchQueue.main.async {
                self.connected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
