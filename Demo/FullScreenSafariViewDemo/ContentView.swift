//
//  ContentView.swift
//  FullScreenSafariViewDemo
//
//  Created by 김동규 on 2020/05/15.
//  Copyright © 2020 Stleam. All rights reserved.
//

import SwiftUI
import FullScreenSafariView

struct ContentView: View {
    
    let repositoryURLString = "https://github.com/stleamist/FullScreenSafariView"
    @State private var showingSafariView = false
    
    var body: some View {
        Button(action: {
            self.showingSafariView.toggle()
        }) {
            Text("Present SafariView")
        }
        .safariView(isPresented: $showingSafariView) {
            URL(string: repositoryURLString)!
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
