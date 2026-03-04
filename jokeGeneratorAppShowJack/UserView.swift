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
                        getJokeAtCertainIndex(id: jID)
                    }
                }
            }

        }
        

    }

    func getJokeAtCertainIndex(id: Int) {

        // creating object of URLSession class to make api call
        let session = URLSession.shared

        //creating URL for api call (you need your apikey)
        // The website has https: if you are not at school.  We delete the s because of the app Transport settings
        let weatherURL = URL(
            string:
                "https://v2.jokeapi.dev/joke/Any?idRange=\(id)"
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
                                    jokes.append("\(j1)\n\n\(j2)")
                                }

                            }
                        } else {
                            print("Error: unable to convert json data")
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
    UserView()
        .environmentObject(AuthViewModel())
}
