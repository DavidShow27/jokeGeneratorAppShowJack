//
//  ContentView.swift
//  jokeGeneratorAppShowJack
//
//  Created by DAVID SHOW on 2/20/26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var auth = AuthViewModel()
    
    var body: some View {
        Group {
            if auth.user != nil {
                HomeView()
                    .environmentObject(auth)
            } else {
                LoginView()
                    .environmentObject(auth)
            }
        }
    }
}

#Preview {
    ContentView()
        .enviormentObject(AuthViewModel())
}
