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
    @State var joke: String = ""
    @State var jokeData: JokeData = JokeData(
        ID: -1,
        like: 0,
        dislike: 0,
        save: false
    )
    @State var jokeID: Int = 0
    @State var jokeLikes: Int = 0
    @State var jokeDislikes: Int = 0

    @State var liked = false
    @State var disliked = false

    var body: some View {
        VStack(spacing: 20) {

            HStack(spacing: 20) {

                Text("QuickQuip")
                    .font(.largeTitle)

                Button("Sign Out") {
                    try? auth.signOut()
                }

            }

            ZStack {

                RoundedRectangle(cornerRadius: 50)
                    .foregroundStyle(.gray)

                Text(joke)
                    .font(.largeTitle)
                
                //putting favorite button in top right
                VStack{
                    HStack{
                        Spacer()
                        Button {
                            print("Favorited")
                        } label: {
                            Image(systemName: "star")
                        }
                        .font(.title)
                        .padding(.trailing, 30)
                        .padding(.top, 30)
                        

                    }
                    Spacer()
                }

            }

            HStack(spacing: 20) {

                VStack {

                    Button("Like", systemImage: "hand.thumbsup.fill") {

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
                    }
                    .buttonStyle(.borderedProminent)

                    Text("\(jokeData.like)")

                }

                VStack {

                    Button("Dislike", systemImage: "hand.thumbsdown.fill") {

                        if !disliked {
                            jokeDislikes += 1
                            if liked {
                                jokeLikes -= 1
                                liked = false
                            }
                            disliked = true
                        } else {
                            jokeDislikes -= 1
                            disliked = false
                        }

                        let d = [
                            "id": jokeID, "likes": jokeLikes,
                            "dislikes": jokeDislikes,
                        ]
                        jokeData.updateToFirebase(dict: d)
                    }
                    .buttonStyle(.borderedProminent)

                    Text("\(jokeData.dislike)")

                }
            }
            Button("New Joke") {
                liked = false
                disliked = false
                getJoke()
            }
            .buttonStyle(.borderedProminent)

            
            HStack{
                
                NavigationLink("Favorites"){
                }
                .buttonStyle(.borderedProminent)
//                .foregroundStyle(.white)
//                .background(.blue)
                .padding(20)
                
                Spacer()
                
                NavigationLink("Leaderboard"){
                }
                .buttonStyle(.borderedProminent)
//                .foregroundStyle(.white)
//                .background(.blue)
                .padding(20)
                
            }
            
        }
        .onAppear {
            getJoke()
            observeDatabase()
        }
    }

    func observeDatabase() {

        ref.child("Jokes").observe(.childChanged, with: { snapshot in
            
                let data = snapshot.value as! [String: Any]
                let j = JokeData(dict: data)
                j.key = snapshot.key
                
                // Update the state to trigger a UI update
                jokeData = j
            })


    }

    func getJoke() {
        
        Task {
            
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

}
#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
