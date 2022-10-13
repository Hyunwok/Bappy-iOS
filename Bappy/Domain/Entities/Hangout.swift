//
//  Hangout.swift
//  Bappy
//
//  Created by 정동천 on 2022/06/22.
//

import Foundation

struct Hangout: Equatable, Identifiable {
    typealias Identifier = String
    
    let id: Identifier
    let state: State
    
    let title: String
    let meetTime: Date
    let language: Language
    let placeID: String
    let placeName: String
    let plan: String
    let limitNumber: Int
    let placeAddress: String
    let categories: [Category]
    
    let coordinates: Coordinates
    
    let postImageURL: URL?
    let openchatURL: URL?
    let mapImageURL: URL?
    
    let participantIDs: [Info]
    var userHasLiked: Bool
    
    static func == (lhs: Hangout, rhs: Hangout) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Hangout {
    struct Info {
        let id: String
        let imageURL: URL?
    }
    
    enum State: String { case available, closed, expired, preview }
    
    enum Category: Int {
        case ALL, Travel, Study, Sports, Food, Drinks, Cook, Culture, Volunteer, Language, Crafting
        
        var description: String {
            switch self {
            case .ALL : return "ALL"
            case .Travel : return "Travel"
            case .Study : return "Study"
            case .Sports : return "Sports"
            case .Food : return "Food"
            case .Drinks : return "Drinks"
            case .Cook : return "Cook"
            case .Culture : return "Cultural Activities"
            case .Volunteer : return "Volunteer"
            case .Language : return "Practice Language"
            case .Crafting : return "Crafting"
            }
        }
    }
    
    enum SortingOrder: Int {
        case Newest, Nearest, ManyViews, manyHearts, lessSeats
        
        var description: String {
            switch self {
            case .Newest: return "Newest"
            case .Nearest: return "Nearest"
            case .ManyViews: return "Many views"
            case .manyHearts: return "Many hearts"
            case .lessSeats: return "Less seats"
            }
        }
    }
    
    enum UserProfileType: Int {
        case Joined, Made, Liked
        
        var description: String {
            switch self {
            case .Joined: return "join"
            case .Made: return "made"
            case .Liked: return "like"
            }
        }
    }
}

struct HangoutPage: Equatable {
    let totalPage: Int
    let hangouts: [Hangout]
}
