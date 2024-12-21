//
//  ar_pricefeedApp.swift
//  ar-pricefeed
//
//  Created by Ankush Singh on 30/09/24.
//

import SwiftUI

@main struct
JustTheMenuApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  var body: some Scene {
    Settings {
      Text("AR Pricefeed")
    }
  }
}
