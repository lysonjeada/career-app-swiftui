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
        let hasPermission = await requestPermission()

        guard hasPermission else {
            errorMessage = "Permita o acesso ao microfone."
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()

            try session.setCategory(
                .playAndRecord,
                mode: .spokenAudio,
                options: [
                    .defaultToSpeaker,
                    .allowBluetooth
                ]
            )

            try session.setActive(true)

            let fileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(
                    "interview-\(UUID().uuidString)"
                )
                .appendingPathExtension("m4a")

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey:
                    AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(
                url: fileURL,
                settings: settings
            )

            audioRecorder?.delegate = self
            audioRecorder?.record()

            recordedFileURL = fileURL
            duration = 0
            isRecording = true

            startTimer()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        audioRecorder = nil

        timerTask?.cancel()
        isRecording = false

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )

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
    }

    private func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance()
                .requestRecordPermission { granted in
                    continuation.resume(
                        returning: granted
                    )
                }
        }
    }

    private func startTimer() {
        timerTask?.cancel()

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(
                    nanoseconds: 1_000_000_000
                )

                guard !Task.isCancelled else {
                    return
                }

                self?.duration += 1
            }
        }
    }
}
