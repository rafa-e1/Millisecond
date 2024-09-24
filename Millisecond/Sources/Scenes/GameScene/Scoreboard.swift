//
//  Scoreboard.swift
//  Millisecond
//
//  Created by RAFA on 9/24/24.
//

import Foundation

struct Scoreboard {
    static func calculateScore(from time: TimeInterval) -> String {
        switch time {
        case 0..<110: return "Top 0.94%"
        case 110..<120: return "Top 2.12%"
        case 120..<130: return "Top 3.62%"
        case 130..<140: return "Top 5.92%"
        case 140..<150: return "Top 9.47%"
        case 150..<160: return "Top 14.80%"
        case 160..<190: return "Top 22.05%"
        case 190..<250: return "Top 30.70%"
        case 250..<270: return "평균 이상"
        case 270..<300: return "평균"
        case 300..<330: return "평균 이하"
        case 330..<350: return "하위 22.13%"
        case 350..<370: return "하위 15.75%"
        case 370..<400: return "하위 10.36%"
        case 400..<450: return "하위 6.18%"
        default: return "하위 3.69%"
        }
    }
}
