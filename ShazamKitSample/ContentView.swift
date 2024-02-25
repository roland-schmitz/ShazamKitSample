//
//  ContentView.swift
//  ShazamKitSample
//
//  Created by Roland Schmitz on 24.02.24.
//

import SwiftUI
import ShazamKit

struct ContentView: View {
    @State private var shazamSession = SHManagedSession()
    @State private var lastResultDescription = ""
    @State private var lastMatch: SHMatch?
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("**State:** \(String(describing: shazamSession.state))")
                    Text("**Last result:** \(String(describing: lastResultDescription))")
                    Text("**Title:** \(lastMatch?.mediaItems.first?.title ?? "-")")
                    Text("**Artist:** \(lastMatch?.mediaItems.first?.artist ?? "-")")
                    Text("**Album:** \(lastMatch?.mediaItems.first?.songs.first?.albumTitle ?? "-")")
                    Text("**Artwork URL:** \(lastMatch?.mediaItems.first?.artworkURL?.absoluteString ?? "-")")
                    Text("**Video URL:** \(lastMatch?.mediaItems.first?.videoURL?.absoluteString ?? "-")")
                    Text("**Web URL:** \(lastMatch?.mediaItems.first?.webURL?.absoluteString ?? "-")")
                    Text("**AppleMusic URL:** \(lastMatch?.mediaItems.first?.appleMusicURL?.absoluteString ?? "-")")
                }
                .textSelection(.enabled)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            }
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                Button("Prepare", systemImage: "record.circle") {
                    Task {
                        clearResults()
                        print("prepare matching")
                        await shazamSession.prepare()
                    }
                }
                .disabled(shazamSession.state != .idle)
                
                Button("Shazam Once", systemImage: "shazam.logo") {
                    Task {
                        clearResults()
                        print("start matching once")
                        let result = await shazamSession.result()
                        handleShazamResult(result)
                    }
                }
                .disabled(shazamSession.state == .matching)
                
                Button("Shazam Nonstop", systemImage: "shazam.logo") {
                    Task {
                        clearResults()
                        print("start matching nonstop")
                        for await result in shazamSession.results {
                            handleShazamResult(result)
                        }
                        print("stopped matching")
                    }
                }
                .disabled(shazamSession.state == .matching)
                
                Button("Cancel", systemImage: "stop") {
                    shazamSession.cancel()
                }
            }
            .font(.title3)
        }
        .padding()
        .onDisappear() {
            shazamSession.cancel()
        }
    }

    @MainActor private func handleShazamResult(_ result: SHSession.Result) {
        switch result {
        case .match(let match):
            print("match: ")
            print("- Title: \(match.mediaItems.first?.title ?? "-")")
            print("- Artist: \(match.mediaItems.first?.artist ?? "-")")
            lastResultDescription = "Match"
            lastMatch = match
        case .noMatch(_):
            print("no match")
            lastResultDescription = "No match"
        case .error(let error, _):
            print("error: \(error)")
            lastResultDescription = "Error: \(error.localizedDescription)"
        }

    }

    private func clearResults() {
        lastResultDescription = ""
        lastMatch = nil
    }
}

#Preview {
    ContentView()
}
