//
//  AppDelegate.swift
//  ar-pricefeed
//
//  Created by Ankush Singh on 30/09/24.
//

import Cocoa
import Foundation
import SwiftUI

// Define a struct to map the response data
struct CryptoResponse: Codable {
    let usd_price: Double
}

// Function to fetch the currency data
func fetchUSDTValue(completion: @escaping (Double?) -> Void) {
    let urlString = "https://price-api.crypto.com/price/v1/token-price/arweave"

    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        completion(nil)
        return
    }

    // Create a URLSession data task to fetch the data
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching data: \(error)")
            completion(nil)
            return
        }

        guard let data = data else {
            print("No data received")
            completion(nil)
            return
        }

        // Decode the JSON response
        do {
            let currencyResponse = try JSONDecoder().decode(
                CryptoResponse.self, from: data)
            let usdtValue = currencyResponse.usd_price
            completion(usdtValue)
        } catch {
            print("Error decoding data: \(error)")
            completion(nil)
        }
    }.resume()
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Create a new status item
        self.statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.target = self
            button.title = "AR $..."
            // Fetch USDT value in a loop with an interval
            DispatchQueue.global().async {
                while true {
                    fetchUSDTValue { usdtValue in
                        if let usdtValue = usdtValue {
                            DispatchQueue.main.async {
                                // Update button title on the main thread
                                let str =
                                    "AR $\(String(format: "%.2f", usdtValue))"
                                button.title = str
                                print(str)
                            }
                        } else {
                            button.title = "AR $error"
                            print("Failed to fetch USDT value")
                        }
                    }
                    sleep(10)  // Wait for 10 seconds before fetching again
                }
            }
        }

    }
}
