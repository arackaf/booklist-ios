import Foundation
import Firebase
import GoogleSignIn

class AuthenticationViewModel: ObservableObject {
    @Published var state: SignInState = .pending
    @Published var imageUrl: URL? = nil
    
    enum SignInState {
        case pending
        case signedIn
        case signedOut
        case loggingIn
        case error
    }
    
    private func signInError(message: String? = nil) {
        if let message {
            print(message)
        }
        if Thread.isMainThread {
            self.state = .error
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.state = .error
            }
        }
    }
    
    func initialize() {
        Task { [weak self] in
            let signedIn = await isSignedIn()
            
            DispatchQueue.main.sync { [weak self] in
                self?.state = signedIn ? .signedIn : .signedOut
            }
        }
    }
    
    func isSignedIn() async -> Bool {
        return await withCheckedContinuation { continuation in
            if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                    self?.imageUrl = user?.profile?.imageURL(withDimension: 64)

                    if let error {
                        continuation.resume(returning: false)
                    } else {
                        continuation.resume(returning: user != nil)
                    }
                }
            } else {
                continuation.resume(returning: false)
            }
        }
    }
    
    func signIn() {
        self.state = .loggingIn
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.state = .error
            return
        }
        
        let configuration = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] result, error in
            if let error {
                signInError(message: "Error " + error.localizedDescription)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken
            else {
                signInError(message: "No user, or no id token")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [weak self] (cred, error) in
                
                if let error {
                    signInError(message: "Error " + error.localizedDescription)
                    return
                }
                
                guard let user = cred?.user else {
                    signInError(message: "No user")
                    return
                }
                
                self?.state = .signedIn
            }
        }
    }
    
    func getIdToken() async -> String {
        guard let currentUser = Auth.auth().currentUser else { return "" }
        
        return await withCheckedContinuation { continuation in
            currentUser.getIDToken { (token, error) in
                if let error {
                    print("Error getting token", error.localizedDescription);
                    continuation.resume(returning: "")
                    return;
                }
                
                guard let token else {
                    continuation.resume(returning: "")
                    return;
                }
                continuation.resume(returning: token)
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
            }
        }
    }
}
