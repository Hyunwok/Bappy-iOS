//
//  CreateHangoutRequestDTO+Mapping.swift
//  Bappy
//
//  Created by 정동천 on 2022/08/03.
//

import Foundation

struct CreateHangoutRequestDTO: Encodable {
    let hangoutTitle: String
    let hangoutPlan: String
    let hangoutLanguage: String
    let hangoutTotalNum: Int
    let hangoutImageUrl: String
    let hangoutOpenChat: String
    let hangoutCategory: [String]
    let test = "test"
    let placeLatitude: String
    let placeLongitude: String
    let placeAddress: String
    let placeId: String
    let hangoutMeetTime: String
    let placeName: String
}
