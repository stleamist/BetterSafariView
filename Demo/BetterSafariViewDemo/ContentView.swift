//
//  ContentView.swift
//  BetterSafariViewDemo
//
//  Created by 김동규 on 2020/05/15.
//  Copyright © 2020 Stleam. All rights reserved.
//

import SwiftUI
import BetterSafariView

let repositoryURLString = "https://github.com/stleamist/BetterSafariView"
let sheetDocumentURLString = "https://developer.apple.com/documentation/swiftui/view/3352791-sheet"
let navigationLinkDocumentURLString = "https://developer.apple.com/documentation/swiftui/navigationlink"

struct ContentView: View {
    
    @State private var showingBetterSafariView = false
    @State private var showingNaiveSafariViewSheet = false
    
    var body: some View {
        // A NavigationView is just for demonstrating NaiveSafariView with NavigationLink.
        NavigationView {
            VStack(spacing: 8) {
                Spacer()
                
                Button(action: {
                    self.showingBetterSafariView = true
                }) {
                    Text("BetterSafariView with .safariView()")
                }
                .buttonStyle(RoundedButtonStyle(.primary))
                .safariView(isPresented: $showingBetterSafariView) {
                    SafariView(url: URL(string: repositoryURLString)!)
                }
                
                Text("IN COMPARISON WITH")
                    .font(Font.body.smallCaps())
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
                
                Button(action: {
                    self.showingNaiveSafariViewSheet = true
                }) {
                    Text("NaiveSafariView with .sheet()")
                }
                .buttonStyle(RoundedButtonStyle(.secondary))
                .sheet(isPresented: $showingNaiveSafariViewSheet) {
                    NaiveSafariView(url: URL(string: sheetDocumentURLString)!)
                }
                
                NavigationLink(destination: NaiveSafariView(url: URL(string: navigationLinkDocumentURLString)!)) {
                    Text("NaiveSafariView with NavigationLink()")
                }
                .buttonStyle(RoundedButtonStyle(.secondary))
            }
            .padding(16)
            .navigationBarTitle("BetterSafariViewDemo", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
