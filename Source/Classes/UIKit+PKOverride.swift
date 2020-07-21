//
//  UIKit+PKOverride.swift
//  UIKit+PKOverride
//
//  Created by zhanghao on 2020/2/27.
//  Copyright © 2020 Psychokinesis. All rights reserved.
//

import UIKit

// MARK: - IngenuityButton

/**
*  主要提供子视图布局调整功能：
*  1. 支持设置图片相对于 titleLabel 的位置 (imagePosition)
*  2. 支持设置图片和 titleLabel 之间的间距 (imageAndTitleSpacing)
*  3. 支持自定义图片尺寸大小 (imageSpecifiedSize)
*  4. 支持图片和 titleLabel 居中对齐或边缘对齐
*  5. 支持 Auto Layout 以上设置可根据内容自适应
*/
open class IngenuityButton: UIButton {
    
    /// 图片与文字布局位置
    public enum ImagePosition: Int {
        /// 图片在上，文字在下
        case top
        /// 图片在左，文字在右
        case left
        /// 图片在下，文字在上
        case bottom
        /// 图片在右，文字在左
        case right
    }
    
    /// 设置按图标和文字的相对位置，默认为ImagePosition.left
    public var imagePosition: ImagePosition = .left {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 设置图标和文字之间的间隔，默认为10
    public var imageAndTitleSpacing: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 设置图标大小为指定尺寸，默认为zero使用图片自身尺寸
    public var imageSpecifiedSize: CGSize = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    open override func sizeToFit() {
        super.sizeToFit()
        frame.size = sizeThatFits(CGSize.pk.greatestFiniteMagnitude)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        let _size = intrinsicContentSize
        return CGSize(width: min(_size.width, size.width), height: min(_size.height, size.height))
    }
    
    open override var intrinsicContentSize: CGSize {
        guard isImageValid() || isTitleValid() else { return .zero}
        
        let titleSize = getValidTitleSize()
        let imageSize = getValidImageSize()
        let spacing = getValidSpacing()
        
        switch imagePosition {
        case .top, .bottom:
            let height = titleSize.height + imageSize.height + spacing
            let width = max(titleSize.width, imageSize.width)
            return CGSize(width: width, height: height)
        case .left, .right:
            let width = titleSize.width + imageSize.width + spacing
            let height = max(titleSize.height, imageSize.height)
            return CGSize(width: width, height: height)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        guard !bounds.isEmpty else { return }
        
        guard isImageValid() || isTitleValid() else { return }
        
        let titleSize = getValidTitleSize()
        let imageSize = getValidImageSize()
        let spacing = getValidSpacing()
        
        switch imagePosition {
        case .top:
            let contentHeight = imageSize.height + titleSize.height + spacing
            let padding = verticalTop(contentHeight)
            let imageX = (bounds.width - imageSize.width) / 2
            let titleX = (bounds.width - titleSize.width) / 2
            imageView!.frame = CGRect(x: imageX, y: padding, size: imageSize)
            titleLabel!.frame = CGRect(x: titleX, y: imageView!.frame.maxY + spacing, size: titleSize)
        case .left:
            let contentWidth = titleSize.width + imageSize.width + spacing
            let padding = horizontalLeft(contentWidth)
            let imageY = (bounds.height - imageSize.height) / 2
            let titleY = (bounds.height - titleSize.height) / 2
            imageView!.frame = CGRect(x: padding , y: imageY, size: imageSize)
            titleLabel!.frame = CGRect(x: imageView!.frame.maxX + spacing, y: titleY, size: titleSize)
        case .bottom:
            let contentHeight = imageSize.height + titleSize.height + spacing
            let padding = verticalTop(contentHeight)
            let imageX = (bounds.width - imageSize.width) / 2
            let titleX = (bounds.width - titleSize.width) / 2
            titleLabel!.frame = CGRect(x: titleX, y: padding, size: titleSize)
            imageView!.frame = CGRect(x: imageX, y: titleLabel!.frame.maxY + spacing, size: imageSize)
        case .right:
            let contentWidth = titleSize.width + imageSize.width + spacing
            let padding = horizontalLeft(contentWidth)
            let imageY = (bounds.height - imageSize.height) / 2
            let titleY = (bounds.height - titleSize.height) / 2
            titleLabel!.frame = CGRect(x: padding, y: titleY, size: titleSize)
            imageView!.frame = CGRect(x: titleLabel!.frame.maxX + spacing , y: imageY, size: imageSize)
        }
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        layoutIfNeeded()
    }
    
    private func horizontalLeft(_ width: CGFloat) -> CGFloat {
        switch contentHorizontalAlignment {
        case .left: return CGFloat(0)
        case .right: return bounds.width - width
        default: /// Other types regarded as .center
            return (bounds.width - width) / 2
        }
    }
    
    private func verticalTop(_ height: CGFloat) -> CGFloat {
        switch contentVerticalAlignment {
        case .top: return CGFloat(0)
        case .bottom: return bounds.height - height
        default: /// Other types regarded as .center
            return (bounds.height - height) / 2
        }
    }
    
    private func getValidTitleSize() -> CGSize {
        guard isTitleValid() else { return .zero }
        return titleLabel!.intrinsicContentSize
    }
    
    private func getValidImageSize() -> CGSize {
        guard isImageValid() else { return .zero }
        return imageSpecifiedSize.pk.isValid ? imageSpecifiedSize : imageView!.bounds.size
    }
    
    private func getValidSpacing() -> CGFloat {
        guard isImageValid(), isTitleValid() else { return .zero }
        return imageAndTitleSpacing
    }
    
    private func isImageValid() -> Bool { currentImage != nil }
    
    private func isTitleValid() -> Bool { (currentTitle != nil || currentAttributedTitle != nil) }
}

private extension CGRect {
    init(x: CGFloat, y: CGFloat, size: CGSize) {
        self.init(x: x, y: y, width: size.width, height: size.height)
    }
}


// MARK: - IngenuityTextField

/**
*  提供以下功能：
*  1. 支持调整左视图边缘留白 (leftViewPadding)
*  2. 支持调整右视图边缘留白 (rightViewPadding)
*  3. 支持调整清除按钮边缘留白 (clearButtonPadding)
*  4. 支持输入框文本边缘留白 (textEdgeInsets)
*  5. 增加键盘删除按钮的响应事件 - IngenuityTextField.deleteBackward
*/
open class IngenuityTextField: UITextField {
    
    
    /// 左视图边缘留白
    public var leftViewPadding: CGFloat = 0
    
    /// 右视图边缘留白
    public var rightViewPadding: CGFloat = 0
    
    /// 清除按钮边缘留白
    public var clearButtonPadding: CGFloat = 0
    
    /// 文本边缘留白
    public var textEdgeInsets: UIEdgeInsets = .zero
    
    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var leftRect = super.leftViewRect(forBounds: bounds)
        leftRect.origin.x += leftViewPadding
        return leftRect
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightRect = super.rightViewRect(forBounds: bounds)
        rightRect.origin.x -= rightViewPadding
        return rightRect
    }
    
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var clearRect = super.clearButtonRect(forBounds: bounds)
        clearRect.origin.x = bounds.size.width - clearRect.size.width - clearButtonPadding
        return clearRect
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return _inputRect(forBounds: bounds, modes: [.always])
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return _inputRect(forBounds: bounds, modes: [.always, .whileEditing])
    }
    
    private func _inputRect(forBounds bounds: CGRect, modes: [ViewMode]) -> CGRect {
        var insets = textEdgeInsets
        
        if let _ = leftView, modes.contains(leftViewMode) {
            insets.left += leftViewRect(forBounds: bounds).maxX
        }
        
        if let _ = rightView, modes.contains(rightViewMode) {
            insets.right += (bounds.width - rightViewRect(forBounds: bounds).minX)
        }
        
        if modes.contains(clearButtonMode) {
            insets.right += (bounds.width - clearButtonRect(forBounds: bounds).minX)
        }
        
        return bounds.inset(by: insets)
    }

    open override func deleteBackward() {
        super.deleteBackward()
        sendActions(for: IngenuityTextField.deleteBackward)
    }
    
    /// 键盘删除按钮的响应事件
    ///
    ///     Usage: textField.addTarget(self, action: #selector(textFieldDeleteBackward(_:)), for: IngenuityTextField.deleteBackward)
    public static var deleteBackward: UIControl.Event {
        return UIControl.Event(rawValue: 2020)
    }
}


// MARK: - IngenuityTextView

/**
*  提供以下功能：
*  1. 支持设置占位文本 (placeholder)
*  2. 支持设置占位文本颜色 (placeholderColor)
*  3. 支持设置占位文本内边距 (placeholderInsets)
*  4. 输入框变化回调 - textDidChange 增加删除监听
*/
open class IngenuityTextView: UITextView {
    
    /// 设置占位文本
    public var placeholder: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 设置占位文本颜色
    public var placeholderColor: UIColor? = .gray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 调整占位文本内边距
    public var placeholderInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        bindNotifications()
    }
    
    public required init?(coder: NSCoder) { super.init(coder: coder) }
    
    public override func draw(_ rect: CGRect) {
        guard !hasText else { return }
        guard let textValue = placeholder else { return }
        let fontValue = font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let colorValue = placeholderColor ?? UIColor.gray
        let attributedText = NSMutableAttributedString(string: textValue)
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(.font, value: fontValue, range: range)
        attributedText.addAttribute(.foregroundColor, value: colorValue, range: range)
        let rect = CGRect(x: placeholderInsets.left,
                          y: placeholderInsets.top,
                          width: bounds.width - placeholderInsets.left - placeholderInsets.right,
                          height: bounds.height - placeholderInsets.top - placeholderInsets.bottom)
        attributedText.draw(in: rect)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    public override var font: UIFont? {
        get {
            return super.font
        } set {
            super.font = newValue
            setNeedsDisplay()
        }
    }
    
    public override var attributedText: NSAttributedString! {
        get {
            return super.attributedText
        } set {
            setNeedsDisplay()
        }
    }
    
    public override var text: String! {
        get {
            return super.text
        } set {
            setNeedsDisplay()
        }
    }
    
    private func bindNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    private func unbindNotifications() {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc private func textDidChange(_ notif: Notification) {
        setNeedsDisplay()
    }
    
    deinit {
        unbindNotifications()
    }
    
    public override func deleteBackward() {
        super.deleteBackward()
        delegate?.textViewDidChange?(self)
    }
}


// MARK: - IngenuityLabel

/// 提供调整UILabel文本内边距功能
open class IngenuityLabel: UILabel {
    
    /// 设置文本内边距
    public var textInsets: UIEdgeInsets = .zero
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = textInsets
        var rect = super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
}
