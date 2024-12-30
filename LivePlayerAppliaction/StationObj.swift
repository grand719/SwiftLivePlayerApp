//
//  StationObjc.swift
//  LivePlayerAppliaction
//
//  Created by Łukasz Pawłowski on 08/12/2024.
//
import Foundation

struct Metadata: Codable {
    let width: Int?
    let format: String?
    let language: String?
    let aspectRatio: String?
    let countries: [String]?
    let type: String?
    let platforms: [String]?
    let height: Int?
}

struct Image: Codable {
    let externalUid: String?
    let sourceUrl: String?
    let metadata: Metadata?
    let purpose: String?
    let cdnUrl: String?
    let id: String?
    let token: String?
    let tags: [String]?
}

struct LiveStreamMetadata: Codable {
    let type: String?
    let contentId: String?
    let streamType: String?
    let drmType: String?
    let adEnabled: Bool?
    let externalAdManager: Bool?
    let liveStream: Bool?
}

struct LiveStream: Codable {
    let streamId: Int?
    let url: String?
    let tags: [String]?
    let metadata: LiveStreamMetadata?
}

struct ExternalResources: Codable {
    let image: [Image]?
    let liveStream: [LiveStream]?
}

struct Relation: Codable {
    let uid: String
    let title: String
}

struct TaxonomyTerm: Codable {
    let draft: Bool
    let value: String
}

struct TaxonomyTerms: Codable {
    let genres: [String: TaxonomyTerm]
    let tags: [String: TaxonomyTerm]
}

struct TaxonomyParentTerms: Codable {
    let genres: [String: String]
    let tags: [String: String]
}

struct ExternalIds: Codable {
    let ceiStationId60125: String
}

struct Station: Codable {
    let channelNumber: Int?
    let title: String?
    let assetType: String?
    let uid: String
    let externalResources: ExternalResources
}

struct ChannelContent {
    let type: String?
    let url: String?
}

struct ChannelImage {
    let url: String?
}

struct Channel {
    let channelNumber: Int?
    let title: String?
    let image: ChannelImage?
    let channelContent: ChannelContent?
    let id: String
}
