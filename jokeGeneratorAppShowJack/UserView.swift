//
//  UserView.swift
//  jokeGeneratorAppShowJack
//
//  Created by DAVID SHOW on 2/26/26.
//

import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import SwiftUI

struct UserView: View {

    @EnvironmentObject var auth: AuthViewModel
    var ref = Database.database().reference()

    @State var jokes: [String] = []
    @State var jokeIDs: [Int] = []

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
                
                ForEach(jokes.indices, id:\.self){i in
                    Text(jokes[i])
                        .swipeActions {
                            Button{
                            
                                let d = ["id": jokeIDs[i]]
                             auth.removeFromFavorites(joke: d)
                                
                                jokes.remove(at: i)
                                jokeIDs.remove(at: i)
                                
                            }label:{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundStyle(.red)
                                    Text("Remove")
                                }
                            }
                        }
                }
//                ForEach(jokes, id: \.self) { joke in
//                        Text(joke)
//                }
                

            }

        }
        .onAppear {
            
            if let user = auth.user {
                    jokes = []
                    jokeIDs = []
                    auth.getFavorites(userID: user.uid) {
                        for jID in auth.favJokes {
                            APICalls().getJokeAt(id: jID) { joke in
                                jokes.append(joke)
                                jokeIDs.append(jID)
                            }
                        }
                    }
                    print(auth.favJokes)
                    
                }

        }
        

    }

}

#Preview {
    UserView()
        .environmentObject(AuthViewModel())
}
