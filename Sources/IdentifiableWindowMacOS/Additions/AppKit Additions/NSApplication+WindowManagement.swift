//
//  NSApplication+WindowManagement.swift
//  ImageReaderApp
//
//  Created by Joseph Wardell on 2/27/25.
//

import AppKit

extension NSApplication {
    func closeAllButMainWindow() {
        for window in NSApplication.shared.windows {
            if !window.isMainWindow {
                window.close()
            }
        }
    }
}

