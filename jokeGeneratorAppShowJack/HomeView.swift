//
//  HomeView.swift
//  jokeGeneratorAppShowJack
//
//  Created by DAVID SHOW on 2/23/26.
//


import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    @State var joke: String = ""
    
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
                
            }

            HStack(spacing: 20) {

                Button("Like", systemImage: "hand.thumbsup.fill") {
                    // Get the ID from Joke to store it into firebase which stores likes and dislikes
                }
                    .buttonStyle(.borderedProminent)

                Button("Dislike", systemImage: "hand.thumbsdown.fill") {
                    // Get the ID from Joke to store it into firebase which stores likes and dislikes
                }
                    .buttonStyle(.borderedProminent)
            }
           Button("New Joke") {
                getJoke()
            }
           .buttonStyle(.borderedProminent)
            
        }
        .onAppear(){
            getJoke()
        }
    }

    func getJoke () {

        // creating object of URLSession class to make api call
        let session = URLSession.shared
    
        //creating URL for api call (you need your apikey)
        // The website has https: if you are not at school.  We delete the s because of the app Transport settings
        let weatherURL = URL(string: "https://v2.jokeapi.dev/joke/Any?blacklistFlags=nsfw,religious,political,racist,sexist,explicit")!
        
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
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                        // print the jsonObj to see structure
                        print(jsonObj)
                        
                       
                            
                        if let j1 = jsonObj.value(forKey: "setup") {
                            if let j2 = jsonObj.value(forKey: "delivery"){
                                
                                DispatchQueue.main.async {
                                    joke = "\(j1)\n\n\(j2)"
                                }
                                
                            }
                        }else {
                                print("Error: unable to convert json data")
                            }
                        }
                    }
                    else {
                        print("Error: Can't convert data to json object")
                    }
//                else {
//                    print("Error: did not receive data")
//                }
            }
        }

        dataTask.resume()

    }
    
}
#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
