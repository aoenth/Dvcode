//
//  ContentView.swift
//  Dvcode
//
//  Created by Peng, Kevin [C] on 2023-03-23.
//

#if canImport(Pasteboard)
import Pasteboard
#endif
import DvorakEncoderDecoder
import SwiftUI

struct ContentView: View {
    @State private var source = ""
    @State private var mode = Mode.decode
    @State private var status = Status.idle
    @FocusState private var focusedField: Field?

    var body: some View {
        Form {
            Section("Source") {
                Toggle("Encode", isOn: .init(get: { mode != .decode }, set: { encode in
                    if mode == .decode {
                        mode = .autoEncode
                    } else {
                        mode = .decode
                    }
                }))
                TextEditor(text: $source)
                    .focused($focusedField, equals: .input)
            }
            Section((mode == .autoEncode ? "Dvorak" : "QWERTY")) {
                Text(result)
            }
            Button("Paste") {
                source = paste()
            }
            Button(status == .copied ? "Copied" : "Copy Result") {
                copy(result)
                showStatus(.copied)
            }
            .foregroundColor(status == .copied ? Color.green : Color.accentColor)
            Button("Swap") {
                source = result
            }
            Button("Clear") {
                source.removeAll()
            }
        }
        .padding()
    }

    var result: String {
        mode != .decode ? source.dvorakEncoded() : source.dvorakDecoded()
    }

    private func showStatus(_ status: Status) {
        Task { @MainActor in
            self.status = status
            try await Task.sleep(nanoseconds: 1_000_000_000)
            self.status = .idle
        }
    }

    enum Status {
        case pasted
        case copied
        case idle
    }

    enum Field: Int, Hashable {
        case input
    }

    enum Mode {
        case autoEncode
        case decode
    }

    private func copy(_ text: String) {
        #if os(macOS)
        setPasteboardContent(text)
        #elseif os(iOS)
        UIPasteboard.general.string = text
        #endif
    }

    private func paste() -> String {
        #if os(macOS)
        return getPasteboardContent()
        #elseif os(iOS)
        return UIPasteboard.general.string ?? ""
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
