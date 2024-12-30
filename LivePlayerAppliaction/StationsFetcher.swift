//
//  StationsFetcher.swift
//  LivePlayerAppliaction
//
//  Created by Łukasz Pawłowski on 08/12/2024.
//

import Foundation

protocol StationsFetcherListener {
    func onFetchEnd(channels: [Channel]) -> Void
}

class StationsFetcher {
    private static let instance = StationsFetcher()
    
    public var delegate: [StationsFetcherListener] = []
    
    private let url = URL(string: "http://localhost:8000/getStations")!
    
    private var channels: [Channel] = []
    
    init(){}
    
    private func configureHeaders(request: URLRequest) -> URLRequest {
        var mutableRequest = request
        return mutableRequest
    }
    
    private func mapStationToChannel(stations: [Station]) -> [Channel] {
        var channelsArray: [Channel] = []

        stations.forEach {station in
            let channelNumber = station.channelNumber ?? 0
            let channelId = station.uid
            let channelTitle = station.title ?? ""
            let channelImage = station.externalResources.image?.first{image in
                let ratio = (image.metadata?.height ?? 0) / (image.metadata?.width ?? 0)
                
                return ratio == 1
            } ?? station.externalResources.image?[0]
            
            let channelContent = station.externalResources.liveStream?[0]
            
            if channelContent?.metadata?.streamType == "mpd" {
                return
            }
            
            let channelObj = Channel(channelNumber: channelNumber, title: channelTitle, image: ChannelImage(url: channelImage?.sourceUrl ?? channelImage?.cdnUrl), channelContent: ChannelContent(type: channelContent?.metadata?.streamType, url: channelContent?.url), id: channelId)
            
            channelsArray.append(channelObj)
        }
        
        return channelsArray
    }
    
    public func getStations() -> [Channel] {
        return channels
    }
    
    public func fetchStations() {
        if self.channels.count > 0 {
            DispatchQueue.main.async {
                self.delegate.forEach{dl in
                    dl.onFetchEnd(channels: self.channels)
                }
            }
            
            return
        }
        
        var request = configureHeaders(request: URLRequest(url: url))
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let error = error {
                print(error)
                return
            }
            
            if let data = data {
                do{
                    let response = try JSONDecoder().decode([Station].self, from: data)
                    let mapedChannels = self.mapStationToChannel(stations: response)
                    self.channels = mapedChannels
                    if self.delegate.count > 0 {
                        DispatchQueue.main.async {
                            self.delegate.forEach{dl in
                                dl.onFetchEnd(channels: mapedChannels)}
                        }
                    }
                }catch let error {
                    print(error)
                }
            }
        }.resume()
    }
    
    
    public static func getInstance() -> StationsFetcher {
        return instance
    }
}
