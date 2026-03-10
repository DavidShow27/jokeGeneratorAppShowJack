//
//  APICalls.swift
//  jokeGeneratorAppShowJack
//
//  Created by DAVID SHOW on 3/4/26.
//

import Foundation

class APICalls {

    func getRandomJoke(complete: @escaping (String, Int) -> Void) {

        var joke: String = ""
        var jokeID: Int = -1

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
                            print("Error: no setup or punchline")
                            
                            if let j3 = jsonObj.value(forKey: "joke") {
                                DispatchQueue.main.async {
                                    joke = "\(j3)"
                                }
                            } else {
                                print("Error: cannot convert json data")
                            }
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

                DispatchQueue.main.async {
                    complete(joke, jokeID)
                }
            }

        }

        dataTask.resume()
    }
    
    func getRandomJokeSeparate(complete: @escaping (String, String, Int) -> Void) {

        var jokeSetup: String = ""
        var jokeDelivery: String = ""
        var jokeID: Int = -1

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
                                    jokeSetup = "\(j1)"
                                    jokeDelivery = "\(j2)"
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

                DispatchQueue.main.async {
                    complete(jokeSetup,jokeDelivery, jokeID)
                }
            }

        }

        dataTask.resume()
    }

    
    func getJokeAt(id: Int, complete: @escaping (String) -> Void) {
        
        var joke: String = ""
        
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
                                    joke = "\(j1)\n\n\(j2)"
                                }

                            }
                        } else {
                            print("Error: no setup or punchline")
                            
                            if let j3 = jsonObj.value(forKey: "joke") {
                                DispatchQueue.main.async {
                                    joke = "\(j3)"
                                }
                            } else {
                                print("Error: cannot convert json data")
                            }
                        }

                    }
                } else {
                    print("Error: Can't convert data to json object")
                }
                
                DispatchQueue.main.async {
                    complete(joke)
                }
            }
        }
        dataTask.resume()
    }

}
