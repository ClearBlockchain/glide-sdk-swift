import XCTest
@testable import glide_sdk_swift

final class magicAuth_sdkTests: XCTestCase {
    
    var magicAuth: MagicAuth? = nil

    override func setUpWithError() throws {
        super.setUp()
        magicAuth = try MagicAuth()
    }

    override func tearDownWithError() throws {
        magicAuth = nil
        super.tearDown()
    }

    func testMagicAuth() async throws {
        // Given
        let dto = StartVerificationDto(phoneNumber: "+41796580164", email: nil, fallbackChannel: .sms)

        // When
        let response = try await magicAuth?.authenticate(startVerificationDto: dto)

        // Then
        XCTAssertEqual(response?.type, VerificationType.magic, "Should return MAGIC verification type.")
        XCTAssertTrue(response!.verified!, "Should return true for verified.")
    }

    func testMagicAuthWithFallback() async throws {
        // Given
        let dto = StartVerificationDto(phoneNumber: "+41796580164", email: nil, fallbackChannel: .sms)

        // When
        let response = try await magicAuth?.authenticate(startVerificationDto: dto)

        // Then
        XCTAssertEqual(response?.type, VerificationType.sms, "Should return SMS verification type.")
    }

    func testVerifyTokenSuccessfully() async throws {
        // Given
        let dto = CheckCodeDto(phoneNumber: "+41796580164", email: nil, code: "981673")

        // When
        let result = try await magicAuth?.checkCode(checkCodeDto: dto)

        // Then
        XCTAssertTrue(result!, "Should return true for successful verification.")
    }
}
