//
//  AppDelegate.swift
//  ar-pricefeed
//
//  Created by Ankush Singh on 30/09/24.
//

import Cocoa
import Foundation
import SwiftUI

struct TokenPair: Codable {
    let baseToken: String
    let quoteToken: String
    let baseSymbol: String
    let quoteSymbol: String
    let baseLogo: String?
    let quoteLogo: String
    let tradeCount24H: Int
    let tradeCount7Days: Int
    let volumeLast24H: String
    let volumeLast7Days: String
    let baseUsdPrice: String?
    let wARUsdPrice: String
    let tokenPriceChange24HPercent: String
    let tokenPriceChange6HPercent: String
    let tokenPriceChange1HPercent: String
    let tokenPriceChange5MinPercent: String
    let greatProcess: String
    let liquidity: String
    let marketCap: String
    let tokenStatus: String
}

// Define tokenPairsResponse as an array of TokenPair
typealias TokenPairsResponse = [TokenPair]

// Update the fetch function to get both prices
func fetchPrices(completion: @escaping (Double?, Double?) -> Void) {
    let permaswapPriceUrl = "https://api-ffpscan.permaswap.network/tokenPairs"
    
    guard let url = URL(string: permaswapPriceUrl) else {
        print("Invalid URL")
        completion(nil, nil)
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching token pairs: \(error)")
            completion(nil, nil)
            return
        }
        
        guard let data = data else {
            print("No data received")
            completion(nil, nil)
            return
        }
        
        do {
            let tokenPairs = try JSONDecoder().decode(TokenPairsResponse.self, from: data)
            
            // Find AO/wUSDC pair
            let aoPrice = tokenPairs.first { pair in
                pair.baseSymbol == "AO" && pair.quoteSymbol == "wUSDC"
            }?.baseUsdPrice.flatMap { Double($0) }
            
            // Find wAR/wUSDC pair
            let arPrice = tokenPairs.first { pair in
                pair.baseSymbol == "wAR" && pair.quoteSymbol == "wUSDC"
            }?.baseUsdPrice.flatMap { Double($0) }
            
            completion(aoPrice, arPrice)
        } catch {
            print("Error decoding token pairs: \(error)")
            completion(nil, nil)
        }
    }.resume()
}

class AppDelegate: NSObject, NSApplicationDelegate {
  var statusItem: NSStatusItem!
  var aboutWindow: NSWindow!
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)
    
    // Create a new status item
    self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    if let button = statusItem.button {
        button.title = "AO $... AR $..."  // Initial two-line display with \n for line break
        button.target = self
        
        // Set smaller font size
        button.font = NSFont.systemFont(ofSize: 12)
        button.alignment = .center
        
        // Enable line wrapping for multiple lines
        button.cell?.wraps = true
        button.cell?.lineBreakMode = .byWordWrapping
        
        // Add right-click (context menu) functionality
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: ""))
        statusItem.menu = menu
    }
    
    // Update the price fetching loop
    DispatchQueue.global().async {
        while true {
            fetchPrices { aoPrice, arPrice in
                DispatchQueue.main.async {
                    if let ao = aoPrice, let ar = arPrice {
                        let str = "AO $\(String(format: "%.2f", ao)) AR $\(String(format: "%.2f", ar))"
                        self.statusItem.button?.title = str
                        print(str)
                    } else {
                        self.statusItem.button?.title = "AO err\nAR err"
                        print("Failed to fetch prices")
                    }
                }
            }
            sleep(10)  // Wait for 10 seconds before fetching again
        }
    }
  }
  
  @objc func quit() {
    NSApp.terminate(self)
  }
  
  @objc func showAbout() {
    let alert = NSAlert()
    alert.alertStyle = .informational
    alert.messageText = "About"
    alert.informativeText = "This app shows the latest known price of the Arweave cryptocurrency"
    alert.addButton(withTitle: "OK")
    alert.runModal()
  }
  
  @objc func showSettings() {
    let alert = NSAlert()
    alert.messageText = "Settings"
    alert.informativeText = "Settings options will be available here."
    alert.addButton(withTitle: "OK")
    alert.runModal()
  }
}
