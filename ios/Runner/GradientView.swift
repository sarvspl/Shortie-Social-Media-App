// *** >>> Google Ad Code <<< ***
import UIKit

// UIColor extension for hex support
extension UIColor {
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let r, g, b: CGFloat
        switch hexString.count {
        case 6:
            r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
            g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255
            b = CGFloat(rgbValue & 0x0000FF) / 255
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        default:
            return nil
        }
    }
}

// GradientView implementation
@IBDesignable
class GradientView: UIView {
    @IBInspectable var startColor: UIColor = UIColor(hex: "8B82FC")! {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor(hex: "D26FF4")! {
        didSet {
            updateGradient()
        }
    }
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
}
