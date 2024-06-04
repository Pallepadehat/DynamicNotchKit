import SwiftUI

public class DynamicNotchImageTextView: DynamicNotch {

    public enum ImagePosition {
        case left
        case right
    }

    /// Construct a new DynamicNotchImageTextView with an asset Image.
    /// - Parameters:
    ///   - image: An optional Image. If left unspecified, the application icon will be used
    ///   - imageSize: The size of the image
    ///   - position: The position of the image (left or right)
    ///   - text: A text for your content
    ///   - style: The popover's style. If unspecified, the style will be automatically set according to the screen.
    public convenience init(assetImage: Image? = nil, imageSize: CGSize = CGSize(width: 40, height: 40), position: ImagePosition = .left, text: String, style: DynamicNotch.Style! = nil) {
        let content = DynamicNotchImageTextView.getView(image: assetImage, imageSize: imageSize, position: position, text: text)
        self.init(content: content, style: style)
    }

    /// Construct a new DynamicNotchImageTextView with an SF Symbol.
    /// - Parameters:
    ///   - systemImage: The SF Symbol's name
    ///   - imageSize: The size of the image
    ///   - position: The position of the image (left or right)
    ///   - text: A text for your content
    ///   - style: The popover's style. If unspecified, the style will be automatically set according to the screen.
    public convenience init(systemImage: String, imageSize: CGSize = CGSize(width: 40, height: 40), position: ImagePosition = .left, text: String, style: DynamicNotch.Style! = nil) {
        let content = DynamicNotchImageTextView.getView(image: Image(systemName: systemImage), imageSize: imageSize, position: position, text: text)
        self.init(content: content, style: style)
    }

    // MARK: Set content

    /// Set new content for the DynamicNotchImageTextView.
    /// - Parameters:
    ///   - image: An optional Image. If left unspecified, the application icon will be used
    ///   - imageSize: The size of the image
    ///   - position: The position of the image (left or right)
    ///   - text: A text for your content
    public func setContent(assetImage: Image? = nil, imageSize: CGSize = CGSize(width: 40, height: 40), position: ImagePosition = .left, text: String) {
        let content = DynamicNotchImageTextView.getView(image: assetImage, imageSize: imageSize, position: position, text: text)
        super.setContent(content: content)
    }

    /// Set new content for the DynamicNotchImageTextView, with an SF Symbol as the image.
    /// - Parameters:
    ///   - systemImage: The SF Symbol's name
    ///   - imageSize: The size of the image
    ///   - position: The position of the image (left or right)
    ///   - text: A text for your content
    public func setContent(systemImage: String, imageSize: CGSize = CGSize(width: 40, height: 40), position: ImagePosition = .left, text: String) {
        let content = DynamicNotchImageTextView.getView(image: Image(systemName: systemImage), imageSize: imageSize, position: position, text: text)
        super.setContent(content: content)
    }

    // MARK: Private
    private static func getView(image: Image?, imageSize: CGSize, position: ImagePosition, text: String) -> some View {
        HStack {
            if position == .left {
                image?
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize.width, height: imageSize.height)
                Text(text)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.leading, 10)
            } else {
                Text(text)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.trailing, 10)
                image?
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize.width, height: imageSize.height)
            }
        }
        .frame(height: max(imageSize.height, 40)) // Ensure the height is at least as tall as the image or 40
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center the content
    }
}
