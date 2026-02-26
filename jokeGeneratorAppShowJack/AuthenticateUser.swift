//
//  AuthenticateUser.swift
//  jokeGeneratorAppShowJack
//
//  Created by DAVID SHOW on 2/23/26.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isAnonymous = false
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            self.isAnonymous = user?.isAnonymous ?? false
        }
    }
    
    init(dict: [String:Any]) {
        
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
    
}

class JokeData {
    
    var ref = Database.database().reference()
    
    var ID: Int
    var like: Int
    var dislike: Int
    var save: Bool
    
    var key = ""

    init(ID: Int, like: Int, dislike: Int, save: Bool) {
        self.ID = ID
        self.like = like
        self.dislike = dislike
        self.save = save
    }
    
    init(dict: [String:Any]) {
        if let ID = dict["id"] as? Int {
            self.ID = ID
        }else{
            ID = -1
        }
        if let like = dict["likes"] as? Int {
            self.like = like
        }else{
            like = 0
        }
        if let dislike = dict["dislikes"] as? Int {
            self.dislike = dislike
        }else{
            dislike = 0
        }
        if let save = dict["save"] as? Bool {
            self.save = save
        }else{
            save = false
        }
    }
    
    func updateToFirebase(dict: [String:Any]) {
        guard let jID = dict["id"] else { return }
        key = "\(jID)"
        ref.child("Jokes").child(key).setValue(dict)
    }
    
}
