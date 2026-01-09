//
//  VideoComponents.swift
//  V2-Dynamic Island
//
//  Ver. 12.0 - Local File Support & URL Factory
//

import SwiftUI
import AVKit
import AVFoundation

// --- FACTORY PARA TRATAMENTO DE URLS ---
struct VideoURLFactory {
    /// Cria uma URL válida a partir de uma string, detectando se é Web ou Local
    static func makeURL(from string: String) -> URL? {
        guard !string.isEmpty else { return nil }
        
        // 1. Se já for um link web ou file protocol explícito
        if string.lowercased().hasPrefix("http") || string.lowercased().hasPrefix("file://") {
            return URL(string: string)
        }
        
        // 2. Se for um caminho absoluto do sistema (/Users/...)
        if string.hasPrefix("/") {
            return URL(fileURLWithPath: string)
        }
        
        // 3. Tentativa de fallback
        return URL(string: string)
    }
}

// --- PLAYER ---
struct LoopingVideoPlayer: NSViewRepresentable {
    var videoURL: URL?
    var gravity: AVLayerVideoGravity = .resizeAspectFill
    
    func makeNSView(context: Context) -> NSView {
        return LoopingPlayerNSView(videoURL: videoURL, gravity: gravity)
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        guard let view = nsView as? LoopingPlayerNSView else { return }
        
        // Verifica se a URL mudou antes de recarregar tudo
        if view.currentURL != videoURL {
            view.setupPlayer(with: videoURL, gravity: gravity)
        }
    }
}

class LoopingPlayerNSView: NSView {
    private var playerLayer: AVPlayerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?
    
    var currentURL: URL?
    
    init(videoURL: URL?, gravity: AVLayerVideoGravity) {
        super.init(frame: .zero)
        self.wantsLayer = true
        setupPlayer(with: videoURL, gravity: gravity)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPlayer(with url: URL?, gravity: AVLayerVideoGravity) {
        // Limpeza de recursos anteriores
        playerLayer.player = nil
        queuePlayer?.removeAllItems()
        self.currentURL = url
        
        guard let url = url else { return }
        
        // Criação do Asset (Suporta Web e Local)
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.isMuted = true
        queuePlayer.actionAtItemEnd = .none
        
        // Loop Infinito
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        self.queuePlayer = queuePlayer
        
        // Configuração da Layer
        playerLayer.player = queuePlayer
        playerLayer.videoGravity = gravity
        playerLayer.frame = self.bounds
        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        
        if self.layer?.sublayers?.contains(playerLayer) == false {
            self.layer?.addSublayer(playerLayer)
        }
        
        queuePlayer.play()
    }
    
    override func layout() {
        super.layout()
        playerLayer.frame = self.bounds
    }
}
