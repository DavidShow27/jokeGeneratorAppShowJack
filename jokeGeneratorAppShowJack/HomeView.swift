//
//  HomeView.swift
//  jokeGeneratorAppShowJack
//
//  Created by DAVID SHOW on 2/23/26.
//

import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

struct HomeView: View {

    var ref = Database.database().reference()  // Reference to Database

    @EnvironmentObject var auth: AuthViewModel  // Reference to User / Authenticator
    @State var jokeData: JokeData = JokeData(  // jokeData instance: Used to get from realtime firebase
        ID: -1,
        like: 0,
        dislike: 0
    )
    @State var jokeID: Int = 0  // ID of the current joke on screen
    @State var jokeLikes: Int = 0  // Local likes (only changes by user)
    @State var jokeDislikes: Int = 0  // Local dislike (only changes by user)

    @State var liked = false
    @State var disliked = false  // Toggle function for buttons
    @State var saved = false

    @State var jokeSetup: String = ""  // Current Joke setup
    @State var jokePunch: String = ""  // Current Joke Delivery / Punchline
    @State var flipped: Bool = false  // if there is both a setup and delivery : can flip the card

    var body: some View {

        NavigationStack {

            VStack(spacing: 20) {

                Text("QuickQuip")
                    //.font(.largeTitle)
                    .font(Font.custom("American Typewriter", size: 72))
                    .foregroundStyle(.white)

                HStack {
                    // Takes user to the login screen
                    Button {
                        try? auth.signOut()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title)
                    }

                    Spacer()
                    // Takes user to the leaderboard, which displays the top jokes from all users
                    NavigationLink(destination: {
                        LeaderboardView()
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.title)
                    }

                    Spacer()
                    // Takes user to the user screen, where they can see their favorites
                    NavigationLink(destination: {
                        UserView()
                    }) {
                        Image(systemName: "person.fill")
                            .font(.title)
                            .opacity(auth.isAnonymous ? 0.3 : 1)
                    }
                    .disabled(auth.isAnonymous)

                }
                .padding()
                .background(Color.gray.opacity(0.1))

                ZStack {

                    RoundedRectangle(cornerRadius: 50)  // Card itself
                        .foregroundStyle(.black)
                        .opacity(0.3)
                    // Card flipping code if there is a unique setup and punchline
                    if flipped {
                        Text(jokePunch)
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .rotation3DEffect(
                                .degrees(180),
                                axis: (x: 0, y: 1, z: 0)
                            )
                    } else {
                        Text(jokeSetup)
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                    }

                }
                .frame(maxWidth: 350, maxHeight: 600)
                .rotation3DEffect(
                    .degrees(flipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .animation(.easeInOut(duration: 0.5), value: flipped)
                .onTapGesture {
                    // Easiest way to check if there's no unique setup or punchline
                    if jokeSetup != jokePunch {
                        flipped.toggle()
                    }
                }

                HStack(spacing: 20) {

                    VStack {
                        // Like button, does the opposite action of dislike
                        Button {

                            if !liked {
                                jokeLikes = 1
                                if disliked {
                                    jokeDislikes = -1
                                    disliked = false
                                }
                                liked = true
                            } else {
                                jokeLikes = -1
                                liked = false
                            }

                            let d = [
                                "id": jokeID,
                                "likes": jokeLikes + jokeData.like,
                                "dislikes": jokeDislikes + jokeData.dislike,
                            ]

                            jokeData.updateToFirebase(dict: d)
                            
                            jokeLikes = 0
                            jokeDislikes = 0

                        } label: {
                            VStack{
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(liked ? .green : .blue)
                                    
                                    VStack{
                                        
                                        Label(
                                            "Like",
                                            systemImage: liked
                                            ? "hand.thumbsup.fill" : "hand.thumbsup"
                                        )
                                        .foregroundStyle(.white)
                                        .padding(2)
                                        
                                        Text("\(jokeData.like)")
                                            .foregroundStyle(.white)
                                    }
                                }
                                .frame(maxWidth: 200, maxHeight: 60)
                                .opacity(auth.isAnonymous ? 0.3 : 1)
                                
                                
                            }
                        }
                        .disabled(auth.isAnonymous)

                        //Text("\(jokeData.like)")

                    }

                    VStack {
                        // Dislike button, does the opposite action of like and favorite
                        Button {

                            if !disliked {
                                jokeDislikes = 1
                                if liked {
                                    jokeLikes = -1
                                    liked = false
                                }
                                disliked = true
                                saved = false
                            } else {
                                jokeDislikes = -1
                                disliked = false
                            }

                            let d = [
                                "id": jokeID,
                                "likes": jokeLikes + jokeData.like,
                                "dislikes": jokeDislikes + jokeData.dislike,
                            ]
                            
                            jokeData.updateToFirebase(dict: d)
                            
                            jokeLikes = 0
                            jokeDislikes = 0
                        } label: {
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(disliked ? .red : .blue)
                                    VStack{
                                        Label(
                                            "Dislike",
                                            systemImage: disliked
                                            ? "hand.thumbsdown.fill"
                                            : "hand.thumbsdown"
                                        )
                                        .foregroundStyle(.white)
                                        .padding(2)
                                        
                                        Text("\(jokeData.dislike)")
                                            .foregroundStyle(.white)

                                    }
                                }
                                .frame(maxWidth: 200, maxHeight: 60)
                                .opacity(auth.isAnonymous ? 0.3 : 1)
                                
                        }
                        .disabled(auth.isAnonymous)
                        
                        //Text("\(jokeData.dislike)")
                        

                    }
                    // Favorite button, similar to the like button but saves to Firestore
                    Button {

                        if !saved {
                            if disliked {
                                jokeDislikes -= 1
                                disliked = false
                            }
                            saved = true
                        } else {
                            saved = false
                        }

                        let d = ["id": jokeID]

                        if saved {
                            auth.addToFavorites(joke: d)
                        } else {
                            auth.removeFromFavorites(joke: d)
                        }

                    } label: {

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(saved ? Color(red: 1, green: 0.5, blue: 0.9) : .blue)
                            Label(
                                "Favorite",
                                systemImage: saved ? "heart.fill" : "heart"
                            )
                            .foregroundStyle(.white)
                        }
                        .frame(maxWidth: 200, maxHeight: 60)
                        .opacity(auth.isAnonymous ? 0.3 : 1)
                    }
                    .disabled(auth.isAnonymous)

                    // Fake Spacer()
                    Text("")

                }
                // New api call
                Button("New Joke") {

                    liked = false
                    disliked = false
                    saved = false
                    flipped = false
                    jokeLikes = 0
                    jokeDislikes = 0

                    APICalls().getRandomJokeSeparate { js, jd, id in
                        jokeSetup = js
                        jokePunch = jd
                        jokeID = id
                        
                        observeDatabase()
                        
                    }

                    // Check the user data to check if id is in their favorites, make button true if it does

                }
                .buttonStyle(.borderedProminent)

            }
            .background(
                LinearGradient(
                    colors: [.mint, .blue],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .onAppear {
            flipped = false
            // Grab joke from an API, in seperate class for cleanliness
            APICalls().getRandomJokeSeparate { js, jd, id in
                jokeSetup = js
                jokePunch = jd
                jokeID = id
                
                // Add listener to Realtime firebase to display global likes and dislikes
                observeDatabase()
                
            }
        }
    }

    func observeDatabase() {
        // Get The ID value and observe the other values aswell
        ref.child("Jokes").child(String(jokeID)).observe(.value, with: { snapshot in
                DispatchQueue.main.async {
                    if let data = snapshot.value as? [String: Any] {
                        let j = JokeData(dict: data)
                        j.key = snapshot.key
                        
                        // Update the state to trigger a UI update
                        jokeData = j
                    } else {
                        print("Didn't get database")
                    }
                }
            }
        )

    }

}
#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
