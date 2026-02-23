//
//  ContentView.swift
//  jokeGeneratorAppShowJack
//
//  Created by DAVID SHOW on 2/20/26.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            Text("QuickQuip")
                .font(.largeTitle)
            
            Spacer()
            
            
        }
        .onAppear(){
            getJoke()
        }
        
    }
    func getJoke(){
        
        let session = URLSession.shared
        
        //creating URL for api call (you need your apikey)
        let weatherURL = URL(
            string:
                ""
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
                    ) as? NSDictionary {
                        print(jsonObj)
                    }
                }
            }
        }
    
        dataTask.resume()
    }
    
}

#Preview {
    ContentView()
}
