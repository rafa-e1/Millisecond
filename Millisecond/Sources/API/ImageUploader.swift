//
//  ImageUploader.swift
//  Millisecond
//
//  Created by RAFA on 10/2/24.
//

import FirebaseStorage

struct ImageUploader {
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }

        let filename = NSUUID().uuidString
        let reference = Storage.storage().reference(withPath: "/profile_images/\(filename)")

        reference.putData(imageData) { metaData, error in
            if let error = error {
                print("DEBUG: Failed to upload image \(error.localizedDescription)")
                return
            }

            reference.downloadURL { url, error in
                guard let imageURL = url?.absoluteString else { return }

                completion(imageURL)
            }
        }
    }
}
