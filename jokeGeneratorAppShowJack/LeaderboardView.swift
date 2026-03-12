//
//  LeaderboardView.swift
//  jokeGeneratorAppShowJack
//
//  Created by JACKSON LISLE on 2/26/26.
//

import Firebase
import FirebaseDatabase
import FirebaseFirestore
import SwiftUI

struct LeaderboardView: View {

    var ref = Database.database().reference()
    @State var allJokes: [JokeData] = []
    @State var jokeWords: [String] = []

    var body: some View {

        VStack {

            Text("Top 10 jokes")
                .foregroundStyle(.white)
                .font(Font.custom("American Typewriter", size: 48))
                .multilineTextAlignment(.center)
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 50)
                    .foregroundStyle(.black)
                    .opacity(0.3)
                
                List {
                    ForEach(Array(jokeWords.indices.prefix(10)), id: \.self) { i in
                        HStack {
                            Text(jokeWords[i])
                            
                            Spacer()
                            
                            Text("Likes: \(allJokes[i].like)")
                            Text("Dislikes: \(allJokes[i].dislike)")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                
            }

            Button("hi") {
                for i in jokeWords {
                    print(i)
                }
                for i in allJokes {
                    print(i.ID)
                }
            }
        }
        .background(
            LinearGradient(
                colors: [.mint, .blue],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {

            fireBaseStuff()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                
                allJokes = allJokes.sorted { $0.like > $1.like }

                for i in allJokes {
                    APICalls().getJokeAt(id: i.ID) { joke in
                        jokeWords.append(joke)
                    }
                }

            }
        }

    }

    func fireBaseStuff() {

        ref.child("Jokes").observe(
            .childAdded,
            with: { (snapshot) in

                let n = snapshot.value as! [String: Any]

                let j = JokeData(dict: n)

                self.allJokes.append(j)

                j.key = snapshot.key
            }
        )

        ref.child("Jokes").observe(
            .childChanged,
            with: { (snapshot) in

                let s = JokeData(dict: snapshot.value as! [String: Any])

                s.key = snapshot.key

                for i in 0..<allJokes.count {
                    if allJokes[i].key == snapshot.key {
                        allJokes[i] = s
                        break
                    }
                }

            }
        )

    }

}

#Preview {
    LeaderboardView()
}
