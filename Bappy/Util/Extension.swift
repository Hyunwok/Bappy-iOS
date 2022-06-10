//
//  Extension.swift
//  Bappy
//
//  Created by 정동천 on 2022/05/10.
//

import UIKit
import RxSwift

extension UIFont {
    enum Family: String {
        case Black, Bold, Light, Medium, Regular, Thin
    }
    
    static func roboto(size: CGFloat, family: Family = .Regular) -> UIFont {
        return UIFont(name: "Roboto-\(family)", size: size)!
    }
}

extension UIImage {
    func downSize(newWidth: CGFloat) -> UIImage {
        guard newWidth < self.size.width else { return self }
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
}

extension UIView {
    func addBappyShadow(shadowOffsetHeight: CGFloat = 2.0) {
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: shadowOffsetHeight)
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 1.0
    }
}

extension Date {
    func isSameDate(with date: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let orgDate = dateFormatter.string(from: self)
        let otherDate = dateFormatter.string(from: date)
        return orgDate == otherDate
    }
    
    func toString(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    func roundUpUnitDigitOfMinutes() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        var string = dateFormatter.string(from: self + 600)
        _ = string.popLast()
        string.append("0")
        return dateFormatter.date(from: string) ?? Date()
    }
}

extension UIViewController {
    func setUpProgressHUD() {
        ProgressHUD.colorBackground = .black.withAlphaComponent(0.05)
        ProgressHUD.colorHUD = .white
        ProgressHUD.colorAnimation = UIColor(named: "bappy_yellow")!
    }
}
