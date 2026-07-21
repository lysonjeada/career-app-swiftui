//
//  AudioRecorderManager.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 21/07/26.
//

import AVFoundation
import Foundation

@MainActor
final class AudioRecorderManager:
    NSObject,
    ObservableObject,
    AVAudioRecorderDelegate {

    @Published private(set) var isRecording = false
    @Published private(set) var duration = 0
    @Published private(set) var recordedFileURL: URL?
    @Published var errorMessage: String?

    private var audioRecorder: AVAudioRecorder?
    private var timerTask: Task<Void, Never>?

    var formattedDuration: String {
        let minutes = duration / 60
        let seconds = duration % 60

        return String(
            format: "%02d:%02d",
            minutes,
            seconds
        )
    }

    func startRecording() async {
        guard !isRecording else {
            return
        }

        let permissionGranted = await requestPermission()

        guard permissionGranted else {
            errorMessage = """
            O acesso ao microfone foi negado. \
            Ative a permissão nos Ajustes do iPhone.
            """
            return
        }

        do {
            try configureAudioSession()

            let fileURL = makeAudioFileURL()

            let recorder = try AVAudioRecorder(
                url: fileURL,
                settings: recordingSettings
            )

            recorder.delegate = self
            recorder.isMeteringEnabled = true

            guard recorder.prepareToRecord() else {
                throw AudioRecorderError.couldNotPrepare
            }

            guard recorder.record() else {
                throw AudioRecorderError.couldNotStart
            }

            audioRecorder = recorder
            recordedFileURL = fileURL
            duration = 0
            isRecording = true

            startTimer()

        } catch {
            stopRecording()
            errorMessage = error.localizedDescription

            print(
                "❌ Erro ao iniciar gravação:",
                error.localizedDescription
            )
        }
    }

    @discardableResult
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        audioRecorder = nil

        timerTask?.cancel()
        timerTask = nil

        isRecording = false

        deactivateAudioSession()

        return recordedFileURL
    }

    func reset() {
        stopRecording()

        if let recordedFileURL {
            try? FileManager.default.removeItem(
                at: recordedFileURL
            )
        }

        self.recordedFileURL = nil
        duration = 0
        errorMessage = nil
    }

    private func requestPermission() async -> Bool {
        if #available(iOS 17.0, *) {
            return await AVAudioApplication
                .requestRecordPermission()
        } else {
            return await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance()
                    .requestRecordPermission { granted in
                        continuation.resume(
                            returning: granted
                        )
                    }
            }
        }
    }

    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()

        try audioSession.setCategory(
            .playAndRecord,
            mode: .default,
            options: [
                .defaultToSpeaker,
                .allowBluetooth
            ]
        )

        try audioSession.setActive(
            true,
            options: .notifyOthersOnDeactivation
        )
    }

    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
        } catch {
            print(
                "⚠️ Erro ao desativar sessão de áudio:",
                error.localizedDescription
            )
        }
    }

    private func makeAudioFileURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "interview-\(UUID().uuidString)"
            )
            .appendingPathExtension("m4a")
    }

    private var recordingSettings: [String: Any] {
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 128_000,
            AVEncoderAudioQualityKey:
                AVAudioQuality.high.rawValue
        ]
    }

    private func startTimer() {
        timerTask?.cancel()

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(
                    for: .seconds(1)
                )

                guard !Task.isCancelled else {
                    return
                }

                self?.duration += 1
            }
        }
    }
}

private enum AudioRecorderError: LocalizedError {
    case couldNotPrepare
    case couldNotStart

    var errorDescription: String? {
        switch self {
        case .couldNotPrepare:
            return "Não foi possível preparar a gravação."

        case .couldNotStart:
            return "Não foi possível iniciar a gravação."
        }
    }
}
