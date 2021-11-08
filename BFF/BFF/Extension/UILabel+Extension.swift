

import UIKit

extension UILabel{
    func countLabelLines() -> Int {
        // Call self.layoutIfNeeded() if your view is uses auto layout
        let myText = self.text! as NSString
        let attributes = [NSAttributedString.Key.font : self.font]

        // swiftlint:disable:next line_length
        let labelSize = myText.boundingRect(with: CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
            return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }

    func isTruncated() -> Bool {
        guard numberOfLines > 0 else { return false }
        return countLabelLines() > numberOfLines
    }
}
