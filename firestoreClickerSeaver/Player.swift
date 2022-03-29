//
//  Player.swift
//  firestoreClickerSeaver
//
//  Created by Brian Seaver on 3/28/22.
//

import Foundation

public class Player: Codable{
    var name: String
    var score: Int
    
    public init(name: String, score: Int){
        self.name = name
        self.score = score
    }
}
