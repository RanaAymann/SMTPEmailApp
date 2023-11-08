//
//  ContentView.swift
//  StoreFile
//
//  Created by Rana Ayman on 06/11/2023.
//

import SwiftUI
//import Mailgun
//import MessageUI
import SwiftSMTP

struct ContentView: View {
    @State private var textToSave: String = ""
    //    @State private var showAlert = false
    @State private var recipientEmail: String = ""

    @StateObject var vm = CoreDataViewModel()
//    @State private var mailComposeViewController: MFMailComposeViewController?

    @State private var userEmail: String = ""
    @State private var userEmailPassword: String = ""
    @State private var emailIsSent: Bool = false
    @State var selectedHostName : String = ""

    let operationQueue = OperationQueue()

    var body: some View {
        VStack {
            TextField("Login Response", text: $textToSave)
                .padding()
            Button("Save to File") {
                //                      saveTextToFile(fileName:"loginResponse")
                // save in core data
                //                       print(textToSave)
                vm.addNewFileData(text: textToSave)
            }.alert(isPresented: $vm.showAlert) {
                Alert(
                    title: Text("File Saved"),
                    message: Text("The file has been saved successfully."),
                    dismissButton: .default(Text("OK"))
                )
            }

            Button("Share file") {
                print(vm.savedEntity?.loginResponse ?? "")
                shareFile()
                //                exportTextAsFileAndShare(text:vm.savedEntity?.loginResponse ?? "",fileName: "test")
            }.padding()
            Text("Select your email client").padding()
            EmailButtonsView()
                .padding().environmentObject(vm)
            TextField("User Email", text: $userEmail).padding()
            SecureField("User email's password", text: $userEmailPassword)
                          .padding()
            TextField("Recipient Email", text: $recipientEmail).padding()
            Button("Send via Email") {
//                sendEmail(userEmail: recipientEmail)
                let operation = BlockOperation {
                    sendEmail(subject: "Test Email", message: "This is a test email sent from SwiftUI")
                }
                operationQueue.addOperation(operation)
            }.alert(isPresented: $emailIsSent) {
                Alert(
                    title: Text("Email Sent Successfully"),
                    message: Text("Your email has been sent successfully."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }


    func shareFile() {
        if vm.customFileName.isEmpty {
            vm.customFileName = "TestFile.txt"
        }
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(vm.customFileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
            } else {
                print("File not found")
            }
        }
    }


//    func sendEmail(userEmail: String) {
//        if MFMailComposeViewController.canSendMail() {
//            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//                let fileAttachment = dir.appendingPathComponent(vm.customFileName)
//                self.mailComposeViewController = MFMailComposeViewController()
//                self.mailComposeViewController?.setToRecipients([userEmail])
//                self.mailComposeViewController?.setSubject("Text file email")
//                self.mailComposeViewController?.setMessageBody("This is the body of the email.", isHTML: false)
//                let fileURL = URL(fileURLWithPath: fileAttachment.path)
//                if let data = try? Data(contentsOf: fileURL) {
//                    self.mailComposeViewController?.addAttachmentData(data, mimeType: "text/plain", fileName: fileAttachment.absoluteString)
//                    UIApplication.shared.windows.first?.rootViewController?.present(   self.mailComposeViewController!, animated: true, completion: nil)
//                }
//            }
//        }   else {
//            print("error in sending email.")
//        }
//    }


//    func sendToEmail() {
//        let message = MailgunMessage(
//            from: "sender@example.com",
//            to: [recipientEmail],
//            subject: "Test Email with Attachment",
//            text: "This is the body of your email with an attachment"
//        )
//        let config = MailgunConfiguration(apiKey: "77dd2b839bc9f3aecc46142cd397a086-8c9e82ec-4a4f64e2")
//        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
//        let client = HTTPClient(eventLoopGroup: eventLoopGroup)
//        let domain = MailgunDomain("sandbox2c07a4c250bd4e859a04285013c36d1d.mailgun.org", .us)
//        let mailgunClient = MailgunClient(config: config, eventLoop: eventLoopGroup, client: client, domain: domain)
//        mailgunClient.send(message)
    //}

    func sendEmail(subject: String, message: String) {
        print(vm.isGmailSelected)
        print(vm.isOutlookSelected)
        if(vm.isGmailSelected){
            selectedHostName = "smtp.gmail.com"
        } else if (vm.isOutlookSelected) {
            selectedHostName = "smtp.office365.com"
        }
        print(selectedHostName)
        let fileData = convertTextFileToData()
        let smtp = SMTP(hostname: selectedHostName, email: userEmail, password: userEmailPassword)
        let attachment = Attachment(data: fileData!, mime: "application/txt", name: "File.txt" )
        let me = Mail.User(email: userEmail)
        let mail = Mail(from: me, to: [Mail.User(email:recipientEmail)], subject: subject, text: message
        , attachments: [attachment])

        smtp.send(mail) { (error) in
            if let error = error {
                print("Error sending email:", error)
                emailIsSent = false
            } else {
                emailIsSent = true
                print("Emails sent successfully")
            }
        }
    }

    func convertTextFileToData() -> Data? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileAttachment = dir.appendingPathComponent(vm.customFileName)
            let fileURL = URL(fileURLWithPath: fileAttachment.path)
            let fileData = try! Data(contentsOf: fileURL)
            return fileData
        }
        return nil
    }

    struct EmailButtonsView: View {
        @EnvironmentObject var vm : CoreDataViewModel

        var body: some View {
            HStack (spacing: 40){
                Button(action: {
                    vm.isGmailSelected = true
                    vm.isOutlookSelected = false
                }) {
                    Image("gmail_icon")
                        .resizable()
                        .frame(width: 50, height: 40)
                }

                Button(action: {
                    vm.isOutlookSelected = true
                    vm.isGmailSelected = false
                }) {
                    Image("outlook_icon")
                        .resizable()
                        .frame(width: 50, height: 40)
                }
            }
        }
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
