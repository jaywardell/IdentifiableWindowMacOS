//
//  ClosesWindowWhenNoLongerMain.swift
//  ImageReaderApp
//
//  Created by Joseph Wardell on 2/27/25.
//

import SwiftUI

@available(macOS 14.0, *)
@MainActor
struct ClosesWindowWhenNoLongerMain: ViewModifier {
    
    @Environment(\.controlActiveState) var controlActiveState
    @Environment(\.dismissWindow) var dismissWindow

    @State private var windowNumber: Int?
    
    var window: NSWindow? {
        guard let windowNumber else { return nil }
        return NSApp.window(withWindowNumber: windowNumber)
    }
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeMainNotification)) { notification in
                guard let mainWindow = notification.object as? NSWindow else { return }
                closeWindowIfNoLongerNeeded(mainWindow)
            }
            .modifier(NSWindowAware())
            .onPreferenceChange(NSWindowNumberPreferenceKey.self) { windowNumber in
                Task {
                    await MainActor.run {
                        self.windowNumber = windowNumber
                    }
                }
            }
            .task {
                await delayedWindowCheck()
            }
    }
    
    private func closeWindowIfNoLongerNeeded(_ mainWindow: NSWindow) {
        if window != mainWindow &&
            nil == mainWindow as? NSPanel {
            window?.performClose(nil)
        }
    }
    
    private func delayedWindowCheck() async {
        try? await Task.sleep(nanoseconds: 200_000_000)

        await MainActor.run {
            guard NSApplication.shared.windows.filter(\.isVisible) != [window] else { return }
            window?.performClose(nil)
        }
    }

}

@available(macOS 14.0, *)
extension View {
    public func closesWindowWhenNoLongerMain() -> some View {
        modifier(ClosesWindowWhenNoLongerMain())
    }
}

@available(macOS 14.0, *)
fileprivate struct NSWindowAware: ViewModifier {
    
    @State var window: NSWindow? = nil

    func body(content: Content) -> some View {
        content
            .getWindow($window)
            .preference(key: NSWindowNumberPreferenceKey.self, value: window?.windowNumber)
    }
}

@available(macOS 14.0, *)
fileprivate struct NSWindowNumberPreferenceKey: PreferenceKey {
    static let defaultValue: Int? = nil

    static func reduce(value: inout Int?, nextValue: () -> Int?) {
        value = nextValue()
    }
}

@available(macOS 14.0, *)
fileprivate  extension View {
    func getWindow(_ wnd: Binding<NSWindow?>) -> some View {
        self.background(WindowAccessor(window: wnd))
    }
}

@available(macOS 14.0, *)
fileprivate  struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?
    
    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }
    
    public func updateNSView(_ nsView: NSView, context: Context) {}
}
