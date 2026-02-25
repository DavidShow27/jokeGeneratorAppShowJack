//
//  LoginView.swift
//  jokeGeneratorAppShowJack
//
//  Created by DAVID SHOW on 2/23/26.
//

// LoginView.swift

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Sign In")
                .font(.largeTitle)
            
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            Button("Sign In") {
                Task {
                    await signIn()
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Create Account") {
                Task {
                    await signUp()
                }
            }
            
            Divider()
            
            Button("Continue as Guest") {
                Task {
                    await continueAsGuest()
                }
            }
            
            if isLoading {
                ProgressView()
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
        }
        .padding()
    }
    
    private func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter email and password."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await auth.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter email and password."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await auth.signUp(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func continueAsGuest() async {
        isLoading = true
        errorMessage = ""
        
        do {
            try await auth.continueAsGuest()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
