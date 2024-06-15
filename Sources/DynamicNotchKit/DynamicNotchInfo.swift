import SwiftUI

public class DynamicNotchInfo: DynamicNotch {
    public init(iconView: some View, title: String, description: String! = nil, style: DynamicNotch.Style! = nil) {
        super.init(width: 300, height: 40, style: style)
        setContent(iconView: iconView, title: title, description: description)
    }

    public convenience init(icon: Image! = nil, iconColor: Color = .white, title: String, description: String? = nil, style: DynamicNotch.Style! = nil) {
        let iconView = DynamicNotchInfo.getIconView(icon: icon, iconColor: iconColor)
        self.init(iconView: iconView, title: title, description: description, style: style)
    }

    public convenience init(systemImage: String, iconColor: Color = .white, title: String, description: String? = nil, style: DynamicNotch.Style! = nil) {
        self.init(icon: Image(systemName: systemImage), iconColor: iconColor, title: title, description: description, style: style)
    }

    public func setContent(iconView: some View, title: String, description: String! = nil) {
        super.setContent(content: DynamicNotchInfo.getView(iconView: iconView, title: title, description: description))
    }

    public func setContent(icon: Image! = nil, iconColor: Color = .white, title: String, description: String? = nil) {
        let iconView = DynamicNotchInfo.getIconView(icon: icon, iconColor: iconColor)
        setContent(iconView: iconView, title: title, description: description)
    }

    public func setContent(systemImage: String, iconColor: Color = .white, title: String, description: String? = nil) {
        setContent(icon: Image(systemName: systemImage), iconColor: iconColor, title: title, description: description)
    }

    private static func getView(iconView: some View, title: String, description: String! = nil) -> some View {
        HStack {
            iconView

            Spacer()
                .frame(width: 10)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)

                if let description {
                    Text(description)
                        .foregroundColor(.secondary)
                        .font(.caption2)
                }
            }

            Spacer()
        }
        .frame(height: 40)
        .padding(20)
    }

    @ViewBuilder private static func getIconView(icon: Image! = nil, iconColor: Color = .white) -> some View {
        if let image = icon {
            image
                .resizable()
                .foregroundColor(iconColor)
                .padding(3)
                .scaledToFit()
        } else {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .padding(-5)
                .scaledToFit()
        }
    }
}
