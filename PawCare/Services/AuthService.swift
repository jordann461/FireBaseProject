//
//  AuthService.swift
//  FireBaseProject
//
//  Created by kübra demir on 14.05.2026.
//
import FirebaseAuth
import FirebaseFirestore

final class AuthService {

    static let shared = AuthService()

    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()

    private init() {}

    func register(
        name: String,
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        auth.createUser(withEmail: email, password: password) { result, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else { return }

            // Set display name on the Auth profile so currentUser.displayName works
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { _ in }

            let userData: [String: Any] = [
                "uid": user.uid,
                "name": name,
                "email": email,
                "role": "user"
            ]

            self.firestore
                .collection("users")
                .document(user.uid)
                .setData(userData) { error in

                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            
        }
        
    }
    func resetPassword(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        auth.sendPasswordReset(
            withEmail: email
        ) { error in

            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        auth.signIn(withEmail: email, password: password) { result, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(()))
        }
    }
}
