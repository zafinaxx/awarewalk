import SwiftUI

/// 顶部信息栏 — 时间、天气、电量等常驻信息
struct InfoBar: View {
    let time: Date
    let weather: WeatherInfo?
    let batteryLevel: Int
    let theme: HUDTheme

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var body: some View {
        HStack {
            weatherSection
            Spacer()
            timeSection
            Spacer()
            batterySection
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(theme.backgroundColor.opacity(theme.glassOpacity))
        .clipShape(.rect(cornerRadius: theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(theme.primaryColor.opacity(0.2), lineWidth: theme.borderWidth * 0.5)
        )
    }

    // MARK: - 天气

    private var weatherSection: some View {
        HStack(spacing: 6) {
            if let weather {
                Image(systemName: weatherIcon(for: weather.condition))
                    .font(.system(.caption, design: theme.fontDesign.swiftUIDesign))
                    .foregroundStyle(weatherColor(for: weather.condition))
                Text(String(format: "%.0f°", weather.temperature))
                    .font(.system(.caption, design: theme.fontDesign.swiftUIDesign, weight: .medium))
                    .foregroundStyle(theme.textPrimaryColor)
            } else {
                Image(systemName: "cloud.fill")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondaryColor)
                Text("--°")
                    .font(.system(.caption, design: theme.fontDesign.swiftUIDesign))
                    .foregroundStyle(theme.textSecondaryColor)
            }
        }
    }

    // MARK: - 时间

    private var timeSection: some View {
        Text(timeFormatter.string(from: time))
            .font(.system(.subheadline, design: theme.fontDesign.swiftUIDesign, weight: .semibold))
            .foregroundStyle(theme.textPrimaryColor)
    }

    // MARK: - 电量

    private var batterySection: some View {
        HStack(spacing: 4) {
            Image(systemName: batteryIcon)
                .font(.system(.caption, design: theme.fontDesign.swiftUIDesign))
                .foregroundStyle(batteryColor)
            Text("\(batteryLevel)%")
                .font(.system(.caption, design: theme.fontDesign.swiftUIDesign, weight: .medium))
                .foregroundStyle(theme.textPrimaryColor)
        }
    }

    private var batteryIcon: String {
        switch batteryLevel {
        case 0..<25: "battery.25percent"
        case 25..<50: "battery.50percent"
        case 50..<75: "battery.75percent"
        default: "battery.100percent"
        }
    }

    private var batteryColor: Color {
        switch batteryLevel {
        case 0..<20: .red
        case 20..<50: .yellow
        default: .green
        }
    }

    private func weatherIcon(for condition: WeatherInfo.WeatherCondition) -> String {
        switch condition {
        case .sunny: "sun.max.fill"
        case .cloudy: "cloud.fill"
        case .rainy: "cloud.rain.fill"
        case .snowy: "cloud.snow.fill"
        case .windy: "wind"
        case .foggy: "cloud.fog.fill"
        }
    }

    private func weatherColor(for condition: WeatherInfo.WeatherCondition) -> Color {
        switch condition {
        case .sunny: .yellow
        case .cloudy: .gray
        case .rainy: .blue
        case .snowy: .cyan
        case .windy: .mint
        case .foggy: .gray
        }
    }
}
