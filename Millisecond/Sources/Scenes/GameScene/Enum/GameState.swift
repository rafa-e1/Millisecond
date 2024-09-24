//
//  GameState.swift
//  Millisecond
//
//  Created by RAFA on 9/15/24.
//

import Foundation

enum GameState {
    case red, orange, green, result

    var guideText: String {
        switch self {
        case .red: return "초록색 화면이 나타나면 화면을 눌러주세요."
        case .orange: return "초록색 화면이 나타나면 화면을 눌러주세요.\n\n화면을 탭하면 재시작할 수 있습니다."
        case .green, .result: return "화면을 탭하면 재시작할 수 있습니다."
        }
    }
}
