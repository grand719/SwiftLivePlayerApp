//
//  ViewController.swift
//  LivePlayerAppliaction
//
//  Created by Łukasz Pawłowski on 30/11/2024.
//

import UIKit
import AVKit

func fetchImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data, error == nil {
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                completion(image)
            }
        } else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    task.resume()
}

class ViewController: UIViewController {
    private let player = AVPlayer()
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    private var channels: [Channel] = []
    private var currentUrl: String?;
    
    private func setChannels(channels: [Channel]) {
        self.channels = channels

        self.channelsList.reloadData()
        if let channelContent = channels[0].channelContent, let url = channelContent.url {
            let initialIndex = IndexPath(row: 0, section: 0)
            self.play(source: url)
            self.channelsList.selectRow(at: initialIndex, animated: false, scrollPosition: .top)
        }
    }
    
    lazy var playerOverlay = {
        var playerOverlay = PlayerOverlay(player: self.player)
        playerOverlay.translatesAutoresizingMaskIntoConstraints = false
        playerOverlay.delegate = self
        return playerOverlay
    }()
    
    lazy var playerView = {
        var playerView = PlayerView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        return playerView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        return activityIndicator
    }()
    
    lazy var channelsList: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChannelTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black.withAlphaComponent(0.4)
        tableView.layer.cornerRadius = 10
        return tableView
    }()
    
    lazy var errorLabel: ErrorLabel = {
        let label = ErrorLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 15
        label.backgroundColor = .black
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new, .initial], context: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        playerView.addGestureRecognizer(tapGesture)
        
        playerView.player = player
        playerView.playerViewId = 10
        
        setupUI()
        StationsFetcher.getInstance().fetchStations()
        StationsFetcher.getInstance().delegate.append(self)
    }
    

     func play(source: String) {
        guard let url = URL(string: source) else { return }
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        player.replaceCurrentItem(with: playerItem)
        currentUrl = source
        player.play()
    }
    
    private func retryPlayback() {
        if((currentUrl) != nil) {
            self.play(source: currentUrl!)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == #keyPath(AVPlayer.status) || keyPath == #keyPath(AVPlayer.currentItem.status)){
            let newStatus: AVPlayerItem.Status
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue)!
            } else {
                newStatus = .unknown
            }
                
            if newStatus == .failed && !errorLabel.getIsErrorPresent() {
                print((player.currentItem?.error?.localizedDescription ?? "No error message"))
                errorLabel.setLabelErrorMessage(message: player.currentItem?.error?.localizedDescription ?? "No error message")
                self.retryPlayback()
            }
            }else if keyPath == #keyPath(AVPlayer.timeControlStatus) {
            if let player = object as? AVPlayer {
                switch player.timeControlStatus {
                case .waitingToPlayAtSpecifiedRate:
                    activityIndicator.startAnimating()
                case .playing:
                    activityIndicator.stopAnimating()
                    errorLabel.clearLabelErrorMessageError()
                case .paused:
                    activityIndicator.stopAnimating()
                @unknown default:
                    break
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if !UIApplication.shared.isLandscape{
            NSLayoutConstraint.deactivate(self.landscapeConstraints)
            NSLayoutConstraint.activate(self.portraitConstraints)
            playerOverlay.isHidden = true
            channelsList.isHidden = false
        } else {
            NSLayoutConstraint.deactivate(self.portraitConstraints)
            NSLayoutConstraint.activate(self.landscapeConstraints)
            playerOverlay.isHidden = false
            channelsList.isHidden = true
        }
    }
    
    @objc func onTap(_ gesture:UIGestureRecognizer) {
        if(gesture.state == .ended) {
            
            if UIDevice.current.orientation.isPortrait {
                return
            }
            
            if playerOverlay.isHidden {
                playerOverlay.isHidden = false
            } else {
                playerOverlay.isHidden = true
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(playerView)
        view.addSubview(playerOverlay)
        view.addSubview(errorLabel)
        view.addSubview(activityIndicator)
        view.addSubview(channelsList)
        
        playerOverlay.playerReference = player
        
        activityIndicator.centerXAnchor.constraint(equalTo: playerView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: playerView.centerYAnchor).isActive = true
        errorLabel.centerXAnchor.constraint(equalTo: playerView.centerXAnchor).isActive = true
        errorLabel.centerYAnchor.constraint(equalTo: playerView.centerYAnchor).isActive = true
        errorLabel.widthAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 0.7).isActive = true
        errorLabel.heightAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 0.7).isActive = true
     
        portraitConstraints = [
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            playerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            playerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
            
            playerOverlay.leadingAnchor.constraint(equalTo: playerView.leadingAnchor),
            playerOverlay.trailingAnchor.constraint(equalTo: playerView.trailingAnchor),
            playerOverlay.topAnchor.constraint(equalTo: playerView.topAnchor),
            playerOverlay.bottomAnchor.constraint(equalTo: playerView.bottomAnchor),
            
            channelsList.topAnchor.constraint(equalTo: playerView.bottomAnchor),
            channelsList.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            channelsList.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
         ]
         
        landscapeConstraints = [
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            playerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            playerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            
            playerOverlay.leadingAnchor.constraint(equalTo: playerView.leadingAnchor),
            playerOverlay.trailingAnchor.constraint(equalTo: playerView.trailingAnchor),
            playerOverlay.topAnchor.constraint(equalTo: playerView.topAnchor),
            playerOverlay.bottomAnchor.constraint(equalTo: playerView.bottomAnchor)
        ]
        

        if !UIApplication.shared.isLandscape {
            NSLayoutConstraint.activate(self.portraitConstraints)
            playerOverlay.isHidden = true
            channelsList.isHidden = false
        }else {
            NSLayoutConstraint.activate(self.landscapeConstraints)
            playerOverlay.isHidden = false
            channelsList.isHidden = true
        }
    }
}

extension ViewController: StationsFetcherListener {
    func onFetchEnd(channels: [Channel]) {
        setChannels(channels: channels)
    }
}

extension ViewController: UITableViewDelegate {}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelTableViewCell", for: indexPath)
        cell.backgroundColor = .clear
        let channel = channels[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .white
        content.secondaryTextProperties.color = .white

        if channel.image != nil && channel.image?.url != nil {
            fetchImage(from: channel.image!.url!) { image in
                if let image = image {
                    let resizedImage = image.resizeImage(to: CGSize(width: 64, height: 64))
                    content.image = resizedImage
                    content.secondaryText = String(channel.channelNumber ?? 0)
                    content.text = channel.title
                    cell.contentConfiguration = content
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = self.channels[indexPath.row]
        self.playerOverlay.setSelectedChannel(channelId: channel.id)
        if let channelContent = channel.channelContent, let url = channelContent.url {
            self.play(source: url)
        }
    }
}

extension ViewController: PlayerOverlayDelegate {
    public  func onChannelChanged(channelId: String) {
        let channelIndex = channels.firstIndex { ch in
            return ch.id == channelId
        }
        
        if channelIndex != nil {
            let initialIndex = IndexPath(row: channelIndex!, section: 0)
            self.channelsList.selectRow(at: initialIndex, animated: false, scrollPosition: .top)
        }
    }
}
