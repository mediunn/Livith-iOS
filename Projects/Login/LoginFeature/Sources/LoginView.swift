import SwiftUI
import DesignSystem

public struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Image.livithImage(.livithLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 60)
            
            Text("Welcome to Livith")
                .notosans(.title)
                .foregroundColor(.livithColor(.black100))
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            Button(action: {
                handleLogin()
            }) {
                Text("Login")
                    .notosans(.title)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.livithColor(.yellow60))
                    .foregroundColor(.livithColor(.white100))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 50)
    }
    
    private func handleLogin() {
        print("Login with \(email)")
    }
}
