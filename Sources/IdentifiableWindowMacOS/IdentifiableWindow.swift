//
//  IdentifiableWindow.swift
//  All Day
//
//  Created by Joseph Wardell on 1/31/23.
//

import SwiftUI

/// A window, of which there can only be one in the app
@available(macOS 14.0, *)
public protocol IdentifiableWindow: View {
    associatedtype WStyle: WindowStyle
    
    static var windowIdentifier: String { get }
    var title: String { get }
    var resizability: WindowResizability { get }
    var windowStyle: WStyle { get }
}

@available(macOS 14.0, *)
public extension IdentifiableWindow {
    
    func window(onAppear: @escaping () -> Void = {}) -> some Scene {
        Window(self.title, id: Self.windowIdentifier) {
            body
                .onAppear(perform: onAppear)
        }
            .windowStyle(windowStyle)
            .windowResizability(resizability)
    }

    func onboardingWindow() -> some Scene {
        window(onAppear: NSApplication.shared.closeAllButMainWindow)
    }
    
}

// MARK: -

@available(macOS 14.0, *)
public protocol IdentifiableUtilityWindow: IdentifiableWindow {}

@available(macOS 14.0, *)
public extension IdentifiableUtilityWindow {
    var resizability: WindowResizability { .contentSize }
    var windowStyle: HiddenTitleBarWindowStyle { .hiddenTitleBar }
}

// MARK: -

@available(macOS 14.0, *)
public extension IdentifiableWindow {
    static func open(_ action: OpenWindowAction) {
        action(Self.self)
    }
}

@available(macOS 14.0, *)
fileprivate extension OpenWindowAction {
    
    func callAsFunction<W>(_ windowIdentifier: W.Type) where W : IdentifiableWindow {
        callAsFunction(id: windowIdentifier.windowIdentifier)
    }
}

// MARK: -

/// A Button that shows an IdentifiableWindow when its action is initiated
@available(macOS 14.0, *)
public struct ShowWindowButton<W: IdentifiableWindow>: View {
    
    let title: String
    let window: W.Type
    let growsToFit: Bool
    
    public init(_ title: String, _ window: W.Type, growsToFit: Bool = false) {
        self.title = title
        self.window = window
        self.growsToFit = growsToFit
    }
    
    @Environment(\.openWindow) var windowOpenAction

    public var body: some View {
        Button {
            window.open(windowOpenAction)
        } label: {
            Text(title)
                .frame(maxWidth: growsToFit ? .infinity : nil)
        }
    }
}

