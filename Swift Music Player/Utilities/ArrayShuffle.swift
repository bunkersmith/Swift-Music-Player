//
//  ArrayShuffle.swift
//  MusicByCarlSwift
//
//  Thanks to Nate Cook for the algorithm, which he posted on this Stack Overflow thread:
//  http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
//

extension Array {
    mutating func shuffle() {
        if count > 0 {
            for i in 0..<(count - 1) {
                let j = Int(arc4random_uniform(UInt32(count - i))) + i
                if i != j {
                    swap(&self[i], &self[j])
                }
            }
        }
    }
}
