//
//  AuthService.swift
//  Millisecond
//
//  Created by RAFA on 10/2/24.
//

import UIKit

import FirebaseAuth
import FirebaseFirestore

struct AuthService {
    static func logUserIn(
        withEmail email: String,
        password: String,
        completion: @escaping(AuthDataResult?, Error?) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }

    static func registerUser(
        withCredential credentials: Credentials,
        completion: @escaping(Error?) -> Void
    ) {
        ImageUploader.uploadImage(image: credentials.profileImage) { imageURL in
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
                if let error = error {
                    print("DEBUG: Failed to register user \(error.localizedDescription)")
                    return
                }

                guard let uid = result?.user.uid else { return }

                let data: [String: Any] = [
                    "uid": uid,
                    "email": credentials.email,
                    "nickname": credentials.nickname,
                    "profileImageURL": imageURL
                ]

                COLLECTION_USERS
                    .document(uid)
                    .setData(data, completion: completion)
            }
        }
    }
}
