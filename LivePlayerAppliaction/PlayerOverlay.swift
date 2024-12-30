import UIKit
import AVKit

class PlayerOverlay: UIView {
    
    public var playerReference: AVPlayer?
    public var selectedChannel: Channel?
    
    public var delegate: PlayerOverlayDelegate?
    
    private var channels: [Channel] = []
    
    lazy var muteButton: UIButton = {
        let configuration = UIButton.Configuration.bordered()
        let button = UIButton(configuration: configuration)
        if let originalImage = UIImage(named: "UnMuteIcon") {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30))
            let resizedImage = renderer.image { _ in
                originalImage.draw(in: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
            }
            button.setImage(resizedImage, for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var listButton: UIButton = {
        let configuration = UIButton.Configuration.bordered()
        let button = UIButton(configuration: configuration)
        if let originalImage = UIImage(named: "ListIcon") {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30))
            let resizedImage = renderer.image { _ in
                originalImage.draw(in: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
            }
            button.setImage(resizedImage, for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var infoButton: UIButton = {
        let configuration = UIButton.Configuration.bordered()
        let button = UIButton(configuration: configuration)
        if let originalImage = UIImage(named: "InfoIcon") {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30))
            let resizedImage = renderer.image { _ in
                originalImage.draw(in: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
            }
            button.setImage(resizedImage, for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var channelsList: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChannelTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black.withAlphaComponent(0.4)
        tableView.isHidden = true
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()
    
    private func setMuteButtonImage() {
        if let originalImage = UIImage(named: playerReference?.volume == 0.0 ? "UnMuteIcon" : "MuteIcon") {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30))
            let resizedImage = renderer.image { _ in
                originalImage.draw(in: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
            }
            muteButton.setImage(resizedImage, for: .normal)
        }
    }
    
    private func setChannels(channels: [Channel]) {
        self.channels = channels

        self.channelsList.reloadData()
        if let channelContent = channels[0].channelContent, let url = channelContent.url {
            let initialIndex = IndexPath(row: 0, section: 0)
            self.delegate?.play(source: url)
            self.channelsList.selectRow(at: initialIndex, animated: false, scrollPosition: .top)
        }
    }
    
    convenience init(player: AVPlayer) {
        self.init(frame: .zero)
        self.playerReference = player
        self.setupView()
        StationsFetcher.getInstance().fetchStations()
        StationsFetcher.getInstance().delegate.append(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerReference = AVPlayer()
    }
    
    required init?(coder: NSCoder) {
        self.playerReference = AVPlayer()

        super.init(coder: coder)    }
    
    @objc func onMutePress(_ sender: UIButton) {
        let playerVolume = playerReference?.volume
        if(playerVolume == 0.0) {
            playerReference?.volume = 1.0
        }else {
            playerReference?.volume = 0.0;
        }
        setMuteButtonImage()

    }
    
    @objc func onListButtonPress(_ sender: UIButton) {
        if channelsList.isHidden {
            channelsList.isHidden = false
        } else {
            channelsList.isHidden = true
        }
    }
    
    @objc func onInfoButtonPress(_ sender: UIButton) {}
    
    private func setupView() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        let separatorView = UIView()
        
        addSubview(stackView)
        addSubview(channelsList)
        stackView.addArrangedSubview(listButton)
        stackView.addArrangedSubview(separatorView)
        stackView.addArrangedSubview(muteButton)
        stackView.addArrangedSubview(infoButton)
        
        muteButton.addTarget(self, action: #selector(onMutePress), for: .touchUpInside)
        listButton.addTarget(self, action: #selector(onListButtonPress), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(onInfoButtonPress), for: .touchUpInside)
        setMuteButtonImage();

        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            listButton.widthAnchor.constraint(equalToConstant: 50),
            listButton.heightAnchor.constraint(equalToConstant: 50),
            
            channelsList.leftAnchor.constraint(equalTo: listButton.leftAnchor),
            channelsList.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 30),
            channelsList.bottomAnchor.constraint(equalTo: listButton.topAnchor),
            channelsList.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4)
        ])
    }
    
    public  func setSelectedChannel(channelId: String) {
        let channelIndex = channels.firstIndex { ch in
            return ch.id == channelId
        }
        
        if channelIndex != nil {
            let initialIndex = IndexPath(row: channelIndex!, section: 0)
            self.channelsList.selectRow(at: initialIndex, animated: false, scrollPosition: .top)
        }
    }
}


extension PlayerOverlay: UITableViewDelegate {}

extension PlayerOverlay: UITableViewDataSource {
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
        self.delegate?.onChannelChanged(channelId: channel.id)
        if let channelContent = channel.channelContent, let url = channelContent.url {
            self.delegate?.play(source: url)
        }
    }
}

extension PlayerOverlay: StationsFetcherListener {
    func onFetchEnd(channels: [Channel]) {
        setChannels(channels: channels)
    }
}

protocol PlayerOverlayDelegate {
    func play(source: String) -> Void
    func onChannelChanged(channelId: String) -> Void
}
