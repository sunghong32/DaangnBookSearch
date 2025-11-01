//
//  LoadingSpinnerView.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import UIKit

final class LoadingSpinnerView: UIView {

    private let shapeLayer = CAShapeLayer()
    private let animationKey = "daangn.spinner.rotation"

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        setupLayer()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }

    func startAnimating() {
        guard shapeLayer.animation(forKey: animationKey) == nil else { return }
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1.0
        animation.repeatCount = .infinity
        layer.add(animation, forKey: animationKey)
    }

    func stopAnimating() {
        layer.removeAnimation(forKey: animationKey)
    }

    private func setupLayer() {
        shapeLayer.strokeColor = UIColor.daangnOrange.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.lineCap = .round
        layer.addSublayer(shapeLayer)
    }

    private func updatePath() {
        let radius = min(bounds.width, bounds.height) / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let startAngle: CGFloat = 0
        let endAngle: CGFloat = CGFloat.pi * 1.5
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        shapeLayer.frame = bounds
        shapeLayer.path = path.cgPath
    }
}


