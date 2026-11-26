//
//  PetsViewModel.swift
//  FireBaseProject
//
//  Created by kübra demir on 1.06.2026.
//

import Foundation

final class PetsViewModel {

    private(set) var pets: [Pet] = []

    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?

    func loadPets() {

        PetService.shared.fetchPets { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let pets):
                    self?.pets = pets
                    self?.onUpdate?()
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }

    func addPet(_ pet: Pet) {

        PetService.shared.addPet(pet) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.pets.append(pet)
                    self?.onUpdate?()
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }

    func deletePet(at index: Int) {

        let pet = pets[index]

        PetService.shared.deletePet(id: pet.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.pets.remove(at: index)
                    self?.onUpdate?()
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
}
