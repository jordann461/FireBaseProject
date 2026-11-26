//
//  VetAIService.swift
//  FireBaseProject
//
//  On-device AI via Apple FoundationModels (iOS 26+, Apple Intelligence)
//

import Foundation
import FoundationModels

@available(iOS 26.0, *)
final class VetAIService {

    static let shared = VetAIService()

    private var session: LanguageModelSession?

    private let instructions = """
    Sen Dr. Paws'sın — PawCare uygulamasındaki şefkatli ve deneyimli bir yapay zeka veteriner asistanısın.
    Evcil hayvan sahiplerine belirti değerlendirmesi, aşı takvimleri, ilaç bilgisi, beslenme tavsiyeleri ve davranış rehberliği konularında yardım ediyorsun.

    Kurallar:
    - Sıcak, anlayışlı ve profesyonel ol
    - Evcil hayvan sahiplerinin anlayabileceği sade ve net bir dil kullan
    - Ciddi belirtiler (nefes güçlüğü, nöbet, şiddetli kanama, olası zehirlenme) için HER ZAMAN acil veteriner bakımı tavsiye et
    - Yanıtları kısa tut — gerçekten gerekmedikçe 150 kelimeyi geçme
    - Her zaman Türkçe yanıt ver
    """

    private init() {}

    // MARK: - Availability

    var isAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability {
            return true
        }
        return false
    }

    var unavailabilityMessage: String {
        guard case .unavailable(let reason) = SystemLanguageModel.default.availability else {
            return ""
        }
        // Use string description to surface the reason to users
        return "Apple Intelligence kullanılamıyor: \(reason)"
    }

    // MARK: - Session

    func resetSession() {
        session = LanguageModelSession(instructions: instructions)
    }

    // MARK: - Generate

    func send(_ message: String) async throws -> String {
        if session == nil {
            session = LanguageModelSession(instructions: instructions)
        }
        let response = try await session!.respond(to: message)
        return response.content
    }
}
