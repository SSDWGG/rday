import MessageUI

@MainActor
final class EmailService: NSObject, MFMailComposeViewControllerDelegate {
    static let shared = EmailService()

    private var completionHandler: (@MainActor (Result<Void, Error>) -> Void)?

    func composeController(
        to recipients: [String] = [],
        subject: String,
        body: String,
        completion: @escaping @MainActor (Result<Void, Error>) -> Void
    ) -> MFMailComposeViewController? {
        guard MFMailComposeViewController.canSendMail() else { return nil }

        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients(recipients)
        controller.setSubject(subject)
        controller.setMessageBody(body, isHTML: false)

        self.completionHandler = completion
        return controller
    }

    nonisolated static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }

    nonisolated func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        Task { @MainActor in
            controller.dismiss(animated: true)
            if let error {
                self.completionHandler?(.failure(error))
            } else {
                self.completionHandler?(.success(()))
            }
            self.completionHandler = nil
        }
    }
}
