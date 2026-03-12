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

            HStack(spacing: 30) {

                Text("QuickQuip")
                    .font(Font.custom("American Typewriter", size: 48))
                    .foregroundStyle(.white)

                Button("Sign Out") {
                    try? auth.signOut()
                }
                .buttonStyle(.borderedProminent)

            }

            Text("Favorites:")
                .font(Font.headline.bold())
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 50)
                    .foregroundStyle(.black)
                    .opacity(0.3)
                
                List {
                    
                    ForEach(jokes.indices, id: \.self) { i in
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
                    
                    
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
                .listRowSpacing(5)
                
            }

        }
        .background(
            LinearGradient(
                colors: [.mint, .blue],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            
            if let user = auth.user {
                    jokes = []
                    jokeIDs = []
                auth.getUserMetaData(userID: user.uid, data: .favorites) {
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
