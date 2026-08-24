//
//  VideoPlaybackAudioSession.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/08/26.
//

import AVFoundation

/// Sem configurar isso, a sessão de áudio padrão do iOS
/// (`.soloAmbient`) respeita a chave lateral de silencioso — o vídeo
/// toca normalmente, mas sem som algum, se o aparelho estiver no
/// modo silencioso. Categoria `.playback` é o padrão usado por apps
/// de vídeo justamente para ignorar essa chave.
enum VideoPlaybackAudioSession {

    static func activate() {
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(
                    .playback,
                    mode: .moviePlayback
                )

            try AVAudioSession.sharedInstance()
                .setActive(true)

        } catch {
            print(
                """
                ⚠️ Não foi possível ativar a sessão \
                de áudio para reprodução de vídeo:

                \(error)
                """
            )
        }
    }

    static func deactivate() {
        do {
            try AVAudioSession.sharedInstance()
                .setActive(
                    false,
                    options:
                        .notifyOthersOnDeactivation
                )

        } catch {
            print(
                """
                ⚠️ Não foi possível desativar a sessão \
                de áudio de vídeo:

                \(error)
                """
            )
        }
    }
}
