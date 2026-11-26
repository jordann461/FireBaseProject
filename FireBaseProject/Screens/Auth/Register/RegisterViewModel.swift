//
//  RegisterViewModel.swift
//  FireBaseProject
//
//  Created by kübra demir on 1.06.2026.
//

import Foundation

final class RegisterViewModel {

    func register(
        name: String,
        email: String,
        password: String,
        completion: @escaping (
            Result<Void, Error>
        ) -> Void
    ) {

        AuthService.shared.register(
            name: name,
            email: email,
            password: password,
            completion: completion
        )
    }
}
