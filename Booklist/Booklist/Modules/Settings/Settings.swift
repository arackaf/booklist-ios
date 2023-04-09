//
//  Settings.swift
//  Booklist
//
//  Created by Adam Rackis on 3/28/23.
//

import SwiftUI

struct Settings: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Settings").foregroundColor(.red)
            Image("kw-short")
                .frame(minWidth: 10)
            Button(action: viewModel.signOut) {
                Text("Sign out")
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
