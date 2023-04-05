//
//  BooklistApp.swift
//  Booklist
//
//  Created by Adam Rackis on 3/28/23.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct GoogleSignInButton: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
  
    private var button = GIDSignInButton()

    func makeUIView(context: Context) -> GIDSignInButton {
        button.colorScheme = .light
        return button
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    private let user = GIDSignIn.sharedInstance.currentUser
    
    var body: some View {
        VStack {
            Text("Logged in")
            Button(action: viewModel.signOut) {
                Text("Sign out")
            }
        }
    }
}

struct LoginView: View {

    @EnvironmentObject var viewModel: AuthenticationViewModel

    var body: some View {
        VStack {

            Text("Login")
                .fontWeight(.black)
                .font(.largeTitle)
                .multilineTextAlignment(.center)

            GoogleSignInButton()
                .padding()
                .onTapGesture {
                    viewModel.signIn()
                }
        }
    }
}

class AuthenticationViewModel: ObservableObject {

    // 1
    enum SignInState {
        case signedIn
        case signedOut
    }

    func signIn() {
      // 1
        if false /*GIDSignIn.sharedInstance.hasPreviousSignIn()*/ {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                
                guard let user = user else { return }
                
                guard let idToken = user.idToken else {return }
                let accessToken = user.accessToken
                 
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                
                print(credential.provider)
                print("prior login", user.userID, user.profile?.email)
                
                self.state = .signedIn
        }
        } else {
            // 2
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
            // 3
            let configuration = GIDConfiguration(clientID: clientID)
        
            // 4
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        

            // 5
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] user, error in
                
                authenticateUser(for: user, with: error)
            }
        }
    }
    
    func signOut() {
        // 1
        GIDSignIn.sharedInstance.signOut()
      
        do {
            // 2
            try Auth.auth().signOut()
        
            state = .signedOut
        } catch {
            print(error.localizedDescription)
        }
    }

    private func authenticateUser(for result: GIDSignInResult?, with error: Error?) {
        // 1
        if let error = error {
            print(error.localizedDescription)
            return
        }
      
        print("authenticate user")
        
        print(result?.user ?? "user is nil")
        
        guard let user = result?.user else { return }
        guard let idToken = user.idToken else { return }
      
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: user.accessToken.tokenString)
      
        Auth.auth().signIn(with: credential) { [unowned self] (cred, error) in
            print("Sign in callback")
            print(user.userID)
            if let error = error {
                print("ERROR LOGGING IN", error.localizedDescription)
            } else {
                self.state = .signedIn
                print("logged in", cred)
            }
        }
    }
    
    // 2
    @Published var state: SignInState = .signedOut
}

@main
struct BooklistApp: App {
    @StateObject var viewModel = AuthenticationViewModel()
    
    init() {
        setupAuthentication()
    }
    
    var body: some Scene {
        WindowGroup {
            Home()
                .environmentObject(viewModel)
        }
    }
    
    private func setupAuthentication() {
        FirebaseApp.configure()
    }
}
