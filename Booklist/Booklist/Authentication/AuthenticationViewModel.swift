import Foundation
import Firebase
import GoogleSignIn

class AuthenticationViewModel: ObservableObject {
    enum SignInState {
        case signedIn
        case signedOut
    }

    func signIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                
                guard let user = user else { return }
                
                guard let idToken = user.idToken else {return }
                let accessToken = user.accessToken
                 
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                
                guard let currentUser = Auth.auth().currentUser else { return }
                
                currentUser.getIDToken { (token, error) in
                    if let error {
                        print("error");
                        return;
                    }
                    
                    if let token {
                        print("currentUserToken")
                        print(token)
                    }
                }
                
                print("idToken", idToken.tokenString)
                print("accessToken", accessToken.tokenString)
                
                print(credential.provider)
                print("prior login", user.userID, user.profile?.email)
                
                self.state = .signedIn
        }
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
            let configuration = GIDConfiguration(clientID: clientID)
        
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] user, error in
                
                authenticateUser(for: user, with: error)
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
      
        do {
            try Auth.auth().signOut()
        
            state = .signedOut
        } catch {
            print(error.localizedDescription)
        }
    }

    private func authenticateUser(for result: GIDSignInResult?, with error: Error?) {
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
                
                guard let user = cred?.user else { return }
                
                user.getIDToken { (token, error) in
                    if let error {
                        print("error");
                        return;
                    }
                    
                    if let token {
                        print("currentUserToken 2")
                        print(token)
                    }
                }
                
            }
        }
    }

    @Published var state: SignInState = .signedOut
}
