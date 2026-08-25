import SwiftUI
import EventKit
import EventKitUI

struct CalendarView: View {
    @State private var isAuthorized = false
    @State private var showingCalendar = false
    private let eventStore = EKEventStore()

    var body: some View {
        VStack {
            if isAuthorized && showingCalendar {
                CalendarContentView()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
            } else {
                Button(action: requestAccess) {
                    Text("Tap to Authorize and Show Calendar")
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
            }
        }
    }

    @MainActor
    private func requestAccess() {
        Task {
            let granted = (try? await eventStore.requestFullAccessToEvents()) ?? false

            isAuthorized = granted
            showingCalendar = granted
        }
    }
}

struct CalendarContentView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let calendarVC = EKEventViewController()
        calendarVC.event = EKEvent(eventStore: EKEventStore()) // Example event
        return calendarVC
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
