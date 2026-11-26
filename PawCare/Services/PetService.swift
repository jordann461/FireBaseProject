import UIKit
import FirebaseAuth
import FirebaseFirestore

final class PetService {

    static let shared = PetService()

    private let db = Firestore.firestore()

    private init() {}

    private var petsRef: CollectionReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid).collection("pets")
    }

    func fetchPets(completion: @escaping (Result<[Pet], Error>) -> Void) {

        guard let ref = petsRef else {
            completion(.success([]))
            return
        }

        ref.order(by: "name").getDocuments { snapshot, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            let pets = snapshot?.documents
                .compactMap { Pet(document: $0.data()) }
                ?? []

            completion(.success(pets))
        }
    }

    func addPet(_ pet: Pet, completion: @escaping (Result<Void, Error>) -> Void) {

        guard let ref = petsRef else {
            completion(.failure(notLoggedInError()))
            return
        }

        ref.document(pet.id).setData(pet.firestoreData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func updatePet(_ pet: Pet, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let ref = petsRef else { completion(.failure(notLoggedInError())); return }
        ref.document(pet.id).setData(pet.firestoreData) { error in
            if let error = error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }

    // Fotoğrafı sıkıştırıp base64 olarak Firestore'a kaydeder (Firebase Storage gerektirmez)
    func savePhoto(_ image: UIImage, petId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let ref = petsRef else { completion(.failure(notLoggedInError())); return }
        guard let data = compress(image) else {
            completion(.failure(NSError(domain: "PetService", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Görsel dönüştürülemedi."])))
            return
        }
        let base64 = "data:image/jpeg;base64," + data.base64EncodedString()
        ref.document(petId).updateData(["photoURL": base64]) { error in
            if let error { completion(.failure(error)) }
            else { completion(.success(base64)) }
        }
    }

    private func compress(_ image: UIImage, maxDimension: CGFloat = 320, quality: CGFloat = 0.5) -> Data? {
        let size = image.size
        let scale = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: quality)
    }

    func deletePet(id: String, completion: @escaping (Result<Void, Error>) -> Void) {

        guard let ref = petsRef else {
            completion(.failure(notLoggedInError()))
            return
        }

        ref.document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    private func notLoggedInError() -> Error {
        NSError(
            domain: "PetService",
            code: 401,
            userInfo: [NSLocalizedDescriptionKey: "User is not logged in."]
        )
    }
}
