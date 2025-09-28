import SwiftUI

public struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Livith")
                .font(.largeTitle)
                .fontWeight(.bold)
            
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
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
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
