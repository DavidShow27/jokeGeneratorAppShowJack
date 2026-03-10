//
//  AuthenticateUser.swift
//  jokeGeneratorAppShowJack
//
//  Created by DAVID SHOW on 2/23/26.
//

import Combine
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import Foundation

class AuthViewModel: ObservableObject {

    @Published var user: User?
    @Published var isAnonymous = false
    var favJokes: [Int] = []

    private var handle: AuthStateDidChangeListenerHandle?
    private var ref = Firestore.firestore()

    init() {
        handle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            self.isAnonymous = user?.isAnonymous ?? false
            if let userID = user?.uid {
                self.getFavorites(userID: userID) {

                }
            }
        }
    }

    init(dict: [String: Any]) {

        handle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            self.isAnonymous = user?.isAnonymous ?? false
        }

    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func continueAsGuest() async throws {
        try await Auth.auth().signInAnonymously()
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    // Escaping makes it so that everything waits until favorites are completely done loading
    func getFavorites(userID: String, completion: @escaping () -> Void) {
        ref.collection("users").document(userID).collection("favorites")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching favorites: \(error)")
                    completion()
                } else {
                    self.favJokes = []
                    for document in snapshot?.documents ?? [] {
                        let data = document.data()
                        if let jokeID = data["id"] as? Int {
                            self.favJokes.append(jokeID)
                        }
                    }
                    completion()
                }
            }
    }

    func addToFavorites(joke: [String: Any]) {

        guard let userID = user?.uid else { return }

        let favoriteRef = ref.collection("users").document(userID).collection(
            "favorites"
        ).document("\(joke["id"] as! Int)")

        favoriteRef.setData(joke) { error in
            if let error = error {
                print("Error adding favorite: \(error)")
            } else {
                self.favJokes.append(joke["id"] as! Int)
            }
        }
    }

    func removeFromFavorites(joke: [String: Any]) {

        guard let userID = user?.uid else { return }

        let favoriteRef = ref.collection("users").document(userID).collection(
            "favorites"
        ).document("\(joke["id"] as! Int)")

        favoriteRef.delete { error in
            if let error = error {
                print("Error removing favorite: \(error)")
            } else {

                if let id = joke["id"] as? Int {
                    self.favJokes.removeAll { $0 == id }
                }

            }
        }
    }

}

class JokeData {

    var ref = Database.database().reference()

    var ID: Int
    var like: Int
    var dislike: Int

    var key = ""

    init(ID: Int, like: Int, dislike: Int) {
        self.ID = ID
        self.like = like
        self.dislike = dislike
    }

    init(dict: [String: Any]) {
        if let ID = dict["id"] as? Int {
            self.ID = ID
        } else {
            ID = -1
        }
        if let like = dict["likes"] as? Int {
            self.like = like
        } else {
            like = 0
        }
        if let dislike = dict["dislikes"] as? Int {
            self.dislike = dislike
        } else {
            dislike = 0
        }
    }

    func updateToFirebase(dict: [String: Any]) {
        guard let jID = dict["id"] else { return }
        key = "\(jID)"
        ref.child("Jokes").child(key).setValue(dict)
    }
    

}
