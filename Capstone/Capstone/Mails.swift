//
//  Mails.swift
//  Capstone
//
//  Created by Christian John on 2018-11-20.
//  Copyright © 2018 Christian John. All rights reserved.
//
import Foundation

class Email: NSObject, NSCoding {
    private enum CoderKeys: String {
        case fromKey
        case fromIDKey
        case toKey
        case toIDKey
        case subjectKey
        case bodyKey
        case dateKey
        case idKey
    }
    
    // MARK: - Properties
    
    /** These properties need @objc to make them key value compliant when filtering using NSPredicate,
     and so they are accessible and usable in Objective-C to interact with other frameworks.
     */
    @objc var from: String
    @objc let fromID: String
    @objc var to: String
    @objc let toID: String
    @objc let subject: String
    @objc let body: String
    @objc let date: Date
    @objc let id: String
    
    var unread = false
    
    // MARK: - NSCoding
    /// This is called for UIStateRestoration
    required init?(coder aDecoder: NSCoder) {
        guard let decodedFrom = aDecoder.decodeObject(forKey: CoderKeys.fromKey.rawValue) as? String else {
            fatalError("No 'from' exist for mail. In your app, handle this gracefully.")
        }
        guard let decodedFromID = aDecoder.decodeObject(forKey: CoderKeys.fromIDKey.rawValue) as? String else {
            fatalError("No 'from' exist for mail. In your app, handle this gracefully.")
        }
        guard let decodedTo = aDecoder.decodeObject(forKey: CoderKeys.toKey.rawValue) as? String else {
            fatalError("No 'from' exist for mail. In your app, handle this gracefully.")
        }
        guard let decodedtoID = aDecoder.decodeObject(forKey: CoderKeys.toIDKey.rawValue) as? String else {
            fatalError("No 'from' exist for mail. In your app, handle this gracefully.")
        }
        guard let decordedSubject = aDecoder.decodeObject(forKey: CoderKeys.subjectKey.rawValue) as? String  else {
            fatalError("No 'subject' exist for mail. In your app, handle this gracefully.")
        }
        guard let decordedBody = aDecoder.decodeObject(forKey: CoderKeys.bodyKey.rawValue) as? String  else {
            fatalError("No 'body' exist for mail. In your app, handle this gracefully.")
        }
        guard let decordedDate = aDecoder.decodeObject(forKey: CoderKeys.dateKey.rawValue) as? Date  else {
            fatalError("No 'date' exist for mail. In your app, handle this gracefully.")
        }
        guard let decodedid = aDecoder.decodeObject(forKey: CoderKeys.idKey.rawValue) as? String else {
            fatalError("No 'id' exist for mail. In your app, handle this gracefully.")
        }
        
        from = decodedFrom
        fromID = decodedFromID
        to = decodedTo
        toID = decodedtoID
        subject = decordedSubject
        body = decordedBody
        date = decordedDate
        id = decodedid
    }
    
    override init() {
        self.from = ""
        self.fromID = ""
        self.to = ""
        self.toID = ""
        self.subject = ""
        self.body = ""
        self.date = Date.init()
        self.unread = false
        self.id = "3"
    }
    
    init(from: String, fromID: String, to: String, toID: String, subject: String, body: String, date: Date, unread: Bool, id: String) {
        self.from = from
        self.fromID = fromID
        self.to = to
        self.toID = toID
        self.subject = subject
        self.body = body
        self.date = date
        self.unread = unread
        self.id = id
    }
    
    var relativeDateString: String {
        if Calendar.current.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: date)
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(from, forKey: CoderKeys.fromKey.rawValue)
        aCoder.encode(fromID, forKey: CoderKeys.fromIDKey.rawValue)
        aCoder.encode(to, forKey: CoderKeys.toKey.rawValue)
        aCoder.encode(toID, forKey: CoderKeys.toIDKey.rawValue)
        aCoder.encode(subject, forKey: CoderKeys.subjectKey.rawValue)
        aCoder.encode(body, forKey: CoderKeys.bodyKey.rawValue)
        aCoder.encode(date, forKey: CoderKeys.dateKey.rawValue)
    }
}

extension Calendar {
    static func now(addingDays days: Int) -> Date {
        return Date().addingTimeInterval(Double(days) * 60 * 60 * 24)
    }
}

//let mockEmails: [Email] = [
//    Email(from: "Realm", to: "Operators", subject: "Video: Operators and Strong Opinions with Erica Sadun", body: "Swift operators are flexible and powerful. They’re symbols that behave like functions, adopting a natural mathematical syntax, for example 1 + 2 versus add(1, 2). So why is it so important that you treat them like potential Swift Kryptonite? Erica Sadun discusses why your operators should be few, well-chosen, and heavily used. There’s even a fun interactive quiz! Play along with “Name That Operator!” and learn about an essential Swift best practice.", date: Calendar.now(addingDays: 0), unread: false, id: "2"),
//    Email(from: "The Pragmatic Bookstore", to: "Operators", subject: "[Pragmatic Bookstore] Your eBook 'Swift Style' is ready for download", body: "Hello, The gerbils at the Pragmatic Bookstore have just finished hand-crafting your eBook of Swift Style. It's available for download at the following URL:", date: Calendar.now(addingDays: 0), unread: false,id: "2"),
//    Email(from: "Instagram", to: "Operators", subject: "mrx, go live and send disappearing photos and videos", body: "Go Live and Send Disappearing Photos and Videos. We recently announced two updates: live video on Instagram Stories and disappearing photos and videos for groups and friends in Instagram Direct.", date: Calendar.now(addingDays: -1), unread: false,id: "2"),
//    Email(from: "Smithsonian Magazine", to: "Operators", subject: "Exclusive Sneak Peek Inside | Untold Stories of the Civil War", body: "For the very first time, the Smithsonian showcases the treasures of its Civil War collections in Smithsonian Civil War. This 384-page, hardcover book takes readers inside the museum storerooms and vaults to learn the untold stories behind the Smithsonian's most fascinating and significant pieces, including many previously unseen relics and artifacts. With over 500 photographs and text from forty-nine curators, the Civil War comes alive.", date: Calendar.now(addingDays: -2), unread: false,id: "2"),
//    Email(from: "Apple News", to: "Operators", subject: "How to Change Your Personality in 90 Days", body: "How to Change Your Personality. You are not stuck with yourself. New research shows that you can troubleshoot personality traits — in therapy.", date: Calendar.now(addingDays: -3), unread: false,id: "2"),
//    Email(from: "Wordpress", to: "Operators", subject: "New WordPress Site", body: "Your new WordPress site has been successfully set up at: http://example.com. You can log in to the administrator account with the following information:", date: Calendar.now(addingDays: -4), unread: false,id: "2"),
//    Email(from: "IFTTT", to: "Operators", subject: "See what’s new & notable on IFTTT", body: "See what’s new & notable on IFTTT. To disable these emails, sign in to manage your settings or unsubscribe.", date: Calendar.now(addingDays: -5), unread: false,id: "2"),
//    Email(from: "Westin Vacations", to: "Operators", subject: "Your Westin exclusive expires January 11", body: "Last chance to book a captivating 5-day, 4-night vacation in Rancho Mirage for just $389. Learn more. No images? CLICK HERE", date: Calendar.now(addingDays: -6), unread: false,id: "2"),
//    Email(from: "Nugget Markets", to: "Operators", subject: "Nugget Markets Weekly Specials Starting February 15, 2017", body: "Scan & Save. For this week’s Secret Special, let’s “brioche” the subject of breakfast. This Friday and Saturday, February 24–25, buy one loaf of Euro Classic Brioche and get one free! This light, soft, hand-braided buttery brioche loaf from France is perfect for an authentic French toast feast. Make Christmas morning extra special with our Signature Recipe for Crème Brûlée French Toast Soufflé!", date: Calendar.now(addingDays: -7), unread: false,id: "2"),
//    Email(from: "GeekDesk", to: "Operators", subject: "We have some exciting things happening at GeekDesk!", body: "Wouldn't everyone be so much happier if we all owned GeekDesks?", date: Calendar.now(addingDays: -8), unread: false,id: "2"),
//    Email(from: "Haroon", to: "Operators", subject: "IMPORTANT Information Session: Saskatchewan Immigrant Nominee Program and Federal Immigration Programs", body: "Dear Students,UR International is hosting an immigration information session about the Federal immigration programs and Saskatchewan Immigrant Nominee Program (SINP). You may qualify for Canadian Immigration.", date: Calendar.now(addingDays: -8), unread: false,id: "2"),
//    Email(from: "Do not reply this email (via UR Courses)", to: "Operators", subject: "This is your Turinitin Digital Receipt", body: "Dear Christian Anwanaodung, \nYou have successfully submitted the file Assignment4.pdf to the assignment Assignment 4 - Due: Monday, November 19 at 11:55 PM in the class CS 350 (Al-Ageili v1): Programming Language Concepts (Moodle PP) on 19-Nov-2018 09:10PM. Your submission id is 1042332663. Your full digital receipt can be viewed and printed from the print/download button in the Document Viewer.", date: Calendar.now(addingDays: -9), unread: false,id: "2")
//]
