//
//  Pet.swift
//  FireBaseProject
//
//  Created by kübra demir on 1.06.2026.
//

import Foundation

struct Pet {

    enum PetType: String, CaseIterable {
        case dog, cat, rabbit, bird, hamster

        var emoji: String {
            switch self {
            case .dog:     return "🐕"
            case .cat:     return "🐈"
            case .rabbit:  return "🐇"
            case .bird:    return "🐦"
            case .hamster: return "🐹"
            }
        }

        var defaultImageName: String {
            switch self {
            case .dog:     return "dog"
            case .cat:     return "cat"
            case .hamster: return "hamster"
            default:       return "pawprint.fill"
            }
        }
    }

    let id: String
    var name: String
    var breed: String
    var age: Int
    var type: PetType
    var imageName: String
    var photoURL: String?

    init(
        id: String = UUID().uuidString,
        name: String,
        breed: String,
        age: Int,
        imageName: String,
        type: PetType = .dog,
        photoURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.imageName = imageName
        self.type = type
        self.photoURL = photoURL
    }

    init?(document: [String: Any]) {
        guard
            let id = document["id"] as? String,
            let name = document["name"] as? String,
            let breed = document["breed"] as? String,
            let age = document["age"] as? Int
        else { return nil }

        self.id = id
        self.name = name
        self.breed = breed
        self.age = age

        let petType = PetType(rawValue: document["type"] as? String ?? "dog") ?? .dog
        self.type = petType
        self.imageName = document["imageName"] as? String ?? petType.defaultImageName
        self.photoURL = document["photoURL"] as? String
    }

    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "name": name,
            "breed": breed,
            "age": age,
            "type": type.rawValue,
            "imageName": imageName
        ]
        if let url = photoURL { data["photoURL"] = url }
        return data
    }
}
