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

    func getJoke () {

        // creating object of URLSession class to make api call
        let session = URLSession.shared
    
        //creating URL for api call (you need your apikey)
        // The website has https: if you are not at school.  We delete the s because of the app Transport settings
        let weatherURL = URL(string: "https://icanhazdadjoke.com/")!
        
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
                        
                        // find main key and get all the values as a dictionary
                        if let mainDictionary = jsonObj.value(forKey: "main") as? NSDictionary {
                            
                            // get the value for the key temp
                            if let temperature = mainDictionary.value(forKey: "temp") {
                                // make it happen on the main thread so it happens during viewDidLoad
                                DispatchQueue.main.async {
                                    // making the value show up on a label
                                    self.weatherLabel.text = "result \(temperature)"
                                }
                              
                            } else {
                                print("Error: unable to find temperature in dictionary")
                            }
                        } else {
                            print("Error: unable to convert json data")
                        }
                    }
                    else {
                        print("Error: Can't convert data to json object")
                    }
                }else {
                    print("Error: did not receive data")
                }
            }
        }

        dataTask.resume()

    }
    
}
#Preview {
    HomeView()
        .enviormentObject(AuthViewModel())
}
