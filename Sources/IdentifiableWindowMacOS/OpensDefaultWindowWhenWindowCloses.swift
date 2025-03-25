//
//  OpensDefaultWindowWhenWindowCloses.swift
//  ImageReaderApp
//
//  Created by Joseph Wardell on 2/27/25.
//

import SwiftUI

@available(macOS 14.0, *)
struct OpensDefaultWindowWhenWindowCloses: ViewModifier {
    
    let windowID: String
    
    @Environment(\.openWindow) var openWindow
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
                guard let windowClosing = notification.object as? NSWindow else { return }
                let visibileWindows = NSApplication.shared.windows.filter(\.isVisible).filter {
                    $0 != windowClosing
                }
                if visibileWindows.isEmpty {
                    openWindow(id: windowID)
                }
            }
    }
}

@available(macOS 14.0, *)
public extension View {
    func opensDefaultWindowOnWindowClose(_ windowID: String) -> some View {
        modifier(OpensDefaultWindowWhenWindowCloses(windowID: windowID))
    }
}
