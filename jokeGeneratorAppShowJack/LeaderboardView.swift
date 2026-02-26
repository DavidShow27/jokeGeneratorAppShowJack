//
//  LeaderboardView.swift
//  jokeGeneratorAppShowJack
//
//  Created by JACKSON LISLE on 2/26/26.
//

import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseFirestore

struct LeaderboardView: View {
    
    var ref = Database.database().reference()

    var body: some View {
        
        
        

    }
//    func fireBaseStuff(){
//        
//        ref.child("jokes").observe(.childChanged) { snapshot in
//            
//            
//            // snapshot is a dictionary with a key and a dictionary as a value
//            // this gets the dictionary from each snapshot
//            let dict = snapshot.value as! [String:Any]
//            
//            // building a Student object from the dictionary
//            let j = JokeData(dict: dict)
//            j.key = snapshot.key
//            // adding the student object to the Student array
//            if students.contains(where: { $0.name == s.name }){
//                return
//            }
//            self.students.append(s)
//            
//            // should only add the student if the student isn’t already in the array
//            // good place to update the tableview also
//        }
//    }
}

#Preview {
    LeaderboardView()
}
