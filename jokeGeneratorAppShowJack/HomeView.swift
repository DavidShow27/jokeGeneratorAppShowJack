//
//  HomeView.swift
//  jokeGeneratorAppShowJack
//
//  Created by DAVID SHOW on 2/23/26.
//


import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Logged In")
            
            Button("Sign Out") {
                try? auth.signOut()
            }
        }
    }
}
#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
