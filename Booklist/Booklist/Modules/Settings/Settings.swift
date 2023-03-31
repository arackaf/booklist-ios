//
//  Settings.swift
//  Booklist
//
//  Created by Adam Rackis on 3/28/23.
//

import SwiftUI

struct Settings: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Settings").foregroundColor(.red)
            Image("kw-short")
                .frame(minWidth: 10)
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
