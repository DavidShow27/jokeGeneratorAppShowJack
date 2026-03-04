//
//  HomeView.swift
//  jokeGeneratorAppShowJack
//
//  Created by DAVID SHOW on 2/23/26.
//

import Firebase
import FirebaseDatabase
import FirebaseFirestore
import SwiftUI

struct HomeView: View {

    var ref = Database.database().reference()

    @EnvironmentObject var auth: AuthViewModel
    @State var joke: String = "Test"
    @State var jokeData: JokeData = JokeData(
        ID: -1,
        like: 0,
        dislike: 0
    )
    @State var jokeID: Int = 0
    @State var jokeLikes: Int = 0
    @State var jokeDislikes: Int = 0

    @State var liked = false
    @State var disliked = false
    @State var saved = false
    
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 20) {
                
                Text("QuickQuip")
                    //.font(.largeTitle)
                    .font(Font.custom("American Typewriter", size: 72))
                
                HStack {
                    
                    NavigationLink(destination: {
                        
                    }) {
                        Image(systemName: "house.fill")
                            .font(.title)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: {
                        LeaderboardView()
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.title)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: {
                        UserView()
                    }) {
                        Image(systemName: "person.fill")
                            .font(.title)
                    }
                    
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 50)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 50))
                    
                    Text(joke)
                        .font(Font.custom("American Typewriter", size: 40))
                    
                }
                .frame(width: 350, height: .infinity)
                
                HStack(spacing: 20) {
                    
                    VStack {
                        
                        Button {
                            
                            if !liked {
                                jokeLikes += 1
                                if disliked {
                                    jokeDislikes -= 1
                                    disliked = false
                                }
                                liked = true
                            } else {
                                jokeLikes -= 1
                                liked = false
                            }
                            
                            let d = [
                                "id": jokeID, "likes": jokeLikes,
                                "dislikes": jokeDislikes,
                            ]
                            
                            jokeData.updateToFirebase(dict: d)
                            
                        } label: {
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(liked ? .green : .blue)
                                Label("Like", systemImage: liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: 200, maxHeight: 60)
                        }
                        
                        
                        Text("\(jokeLikes)")
                        
                    }
                    
                    VStack {
                        
                        Button {
                            
                            if !disliked {
                                jokeDislikes += 1
                                if liked {
                                    jokeLikes -= 1
                                    liked = false
                                }
                                disliked = true
                                saved = false
                            } else {
                                jokeDislikes -= 1
                                disliked = false
                            }
                            
                            let d = [
                                "id": jokeID, "likes": jokeLikes,
                                "dislikes": jokeDislikes,
                            ]
                            jokeData.updateToFirebase(dict: d)
                        } label: {
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(disliked ? .red : .blue)
                                Label("Dislike", systemImage: disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: 200, maxHeight: 60)
                        }
                        
                        Text("\(jokeDislikes)")
                        
                    }
                    
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
                                .foregroundStyle(saved ? .pink : .blue)
                            Label("Favorite", systemImage: saved ? "heart.fill" : "heart")
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: 200, maxHeight: 60)
                    }
                    // Fake Spacer()
                    Text("")
                    
                }
                Button("New Joke") {
                    liked = false
                    disliked = false
                    saved = false
                    jokeLikes = 0
                    jokeDislikes = 0
                    getJoke()
                }
                .buttonStyle(.borderedProminent)
                
            }
            .background (
                LinearGradient(colors: [.mint, .blue], startPoint: .top, endPoint: .bottom)
            )
        }
        .onAppear {
            //getJoke()
            observeDatabase()
        }
    }

    func observeDatabase() {

        ref.child("Jokes").observe(
            .childChanged,
            with: { snapshot in

                let data = snapshot.value as! [String: Any]
                let j = JokeData(dict: data)
                j.key = snapshot.key

                // Update the state to trigger a UI update
                jokeData = j
            }
        )

    }

    func getJoke() {

        // creating object of URLSession class to make api call
        let session = URLSession.shared

        //creating URL for api call (you need your apikey)
        // The website has https: if you are not at school.  We delete the s because of the app Transport settings
        let weatherURL = URL(
            string:
                "https://v2.jokeapi.dev/joke/Any?blacklistFlags=nsfw,religious,political,racist,sexist,explicit"
        )!

        // Making an api call and creating data in the completion handler
        let dataTask = session.dataTask(with: weatherURL) {
            // completion handler: happens on a different thread, could take time to get data

            (data: Data?, response: URLResponse?, error: Error?) in

            if let error = error {
                print("Error:\n\(error)")
            } else {
                // if there is data
                if let data = data {
                    // convert data to json Object
                    if let jsonObj = try? JSONSerialization.jsonObject(
                        with: data,
                        options: .allowFragments
                    )
                        as? NSDictionary
                    {
                        // print the jsonObj to see structure
                        print(jsonObj)

                        if let j1 = jsonObj.value(forKey: "setup") {
                            if let j2 = jsonObj.value(forKey: "delivery") {

                                DispatchQueue.main.async {
                                    joke = "\(j1)\n\n\(j2)"
                                }

                            }
                        } else {
                            print("Error: unable to convert json data")
                        }

                        if let jID = jsonObj.value(forKey: "id") {
                            DispatchQueue.main.async {

                                if let realJID = Int("\(jID)") {
                                    jokeID = Int(realJID)
                                }
                            }
                        }

                    }
                } else {
                    print("Error: Can't convert data to json object")
                }
            }
        }

        dataTask.resume()

    }

}
#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
