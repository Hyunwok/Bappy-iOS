//
//  UserProfileResponseDTO+Mapping.swift
//  Bappy
//
//  Created by 정동천 on 2022/06/28.
//

import Foundation

struct BappyUserResponseDTO: Decodable {
    
    let user: UserDTO
    
    private enum CodingKeys: String, CodingKey {
        case user = "data"
    }
}

extension BappyUserResponseDTO {
    struct UserDTO: Decodable {
        let id: String?
        let name: String?
        let nationality: String?
        let gender: String?
        let birth: String?
        let affiliation: String?
        let introduce: String?
        let profileImageURL: String?
        let state: String
        let languages: [String]?
        let personalities: [String]?
        let interests: [String]?
        
        private enum CodingKeys: String, CodingKey {
            case id = "userInfoID"
            case name = "userName"
            case nationality = "userNationality"
            case gender = "userGender"
            case birth = "userBirth"
            case affiliation = "userAffiliation"
            case introduce = "userIntroduce"
            case profileImageURL = "userProfileImageURL"
            case state = "userState"
            case languages = "userLanguages"
            case personalities = "userPersonalities"
            case interests = "userInterests"
        }
    }
}

extension BappyUserResponseDTO {
    func toDomain() -> BappyUser {
        return BappyUser(
            id: user.id ?? UUID().uuidString,
            state: .normal, // 임시
            coordinates: nil, // 임시
            name: user.name,
            gender: nil, // 임시
            birth: nil, // 임시
            nationality: nil, // 임시
            profileImageURL: user.profileImageURL.flatMap { URL(string: $0) },
            introduce: user.introduce,
            affiliation: user.affiliation,
            languages: user.languages,
            personalities: nil, // 임시
            interests: nil // 임시
        )
    }
}
