import Foundation
import JWTDecode

enum VerificationType: String, Codable {
    case magic = "MAGIC"
    case sms = "SMS"
    case email = "EMAIL"
}

enum FallbackVerificationChannel: String, Codable {
    case sms = "SMS"
    case email = "EMAIL"
}

struct StartVerificationDto: Codable {
    let phoneNumber: String?
    let email: String?
    let fallbackChannel: FallbackVerificationChannel?
}

struct StartVerificationResponseDto: Codable {
    let type: String
    let authUrl: String?
    let verified: Bool?
}

struct VerifyTokenDto: Codable {
    let phoneNumber: String
}

struct CheckCodeDto: Codable {
    let phoneNumber: String?
    let email: String?
    let code: String
}

@available(macOS 12.0, *)
class MagicAuth {
    private var config: GlideConfig

    init() throws {
        self.config = try getGlideConfig()
    }


    func authenticate(startVerificationDto: StartVerificationDto) async throws -> StartVerificationResponseDto {
        let url = URL(string: "\(config.internalUrls.apiBaseUrl)/magic-auth/verification/start")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONEncoder().encode(StartVerificationDto(
            phoneNumber: startVerificationDto.phoneNumber.map { formatPhoneNumber($0) },
            email: startVerificationDto.email,
            fallbackChannel: startVerificationDto.fallbackChannel
        ))
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw HTTPResponseError(response: response)
        }

        var resData = try JSONDecoder().decode(StartVerificationResponseDto.self, from: data)
        if resData.type.lowercased() == VerificationType.magic.rawValue, let authUrl = resData.authUrl, let authURL = URL(string: authUrl) {
            let (authData, authResponse) = try await URLSession.shared.data(from: authURL)
            guard let authHTTPResponse = authResponse as? HTTPURLResponse, authHTTPResponse.statusCode == 200 else {
                throw HTTPResponseError(response: authResponse)
            }


            let jwtToken = String(decoding: authData, as: UTF8.self)
            // Decode JWT without signature verification
            do {
                let jwt = try decode(jwt: jwtToken)
                guard let issuer = jwt.claim(name: "iss").string, issuer == config.internalApiBaseUrl else {
                    throw NSError(domain: "JWTError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JWT issuer"])
                }
                resData.authUrl = nil  // Remove authUrl from the response
            } catch {
                throw NSError(domain: "JWTError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JWT"])
            }

            resData.authUrl = nil  // Remove authUrl from response
        }
        return resData
    }

    func checkCode(checkCodeDto: CheckCodeDto) async throws -> Bool {
        let url = URL(string: "\(config.internalApiBaseUrl)/magic-auth/verification/check-code")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(CheckCodeDto(
            phoneNumber: checkCodeDto.phoneNumber.map { formatPhoneNumber($0) },
            email: checkCodeDto.email,
            code: checkCodeDto.code
        ))
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw HTTPResponseError(response: response)
        }
        let resData = try JSONDecoder().decode(Bool.self, from: data)
        return resData ?? false
    }
}