//
//  ContentView.swift
//  Booklist
//
//  Created by Adam Rackis on 3/28/23.
//

import SwiftUI

struct Home: View {
    var body: some View {
        TabView {
            Books()
                .tabItem {
                    Label("Books", systemImage: "book.circle")
                }
            Settings()
                .tabItem({
                    Label("Settings", systemImage: "gear")
                })
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
