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
