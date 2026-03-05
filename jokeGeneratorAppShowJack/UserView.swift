//
//  UserView.swift
//  jokeGeneratorAppShowJack
//
//  Created by DAVID SHOW on 2/26/26.
//

import FirebaseAuth
import SwiftUI

struct UserView: View {

    @EnvironmentObject var auth: AuthViewModel
    @State var jokes: [String] = []

    var body: some View {

        VStack {

            HStack(spacing: 20) {

                Text("QuickQuip")
                    .font(.largeTitle)

                Button("Sign Out") {
                    try? auth.signOut()
                }
                .buttonStyle(.borderedProminent)

            }

            Text("Favorites:")
                .font(Font.headline.bold())
            List {

                ForEach(jokes, id: \.self) { joke in

                    Text(joke)

                }

            }

        }
        .onAppear {
            jokes.removeAll()

            if let user = auth.user {
                auth.getFavorites(userID: user.uid) {
                    
                    for jID in auth.favJokes {
                        APICalls().getJokeAt(id: jID) { joke in
                            jokes.append(joke)
                        }
                    }
                    
                }
            }

        }
        

    }

}

#Preview {
    UserView()
        .environmentObject(AuthViewModel())
}
