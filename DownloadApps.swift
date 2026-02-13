import AppKit
import SwiftUI
import Combine

// ── App Definitions ─────────────────────────────────────

struct AppInfo {
    let name: String
    let fileName: String
    let urlString: String
}

let appDefinitions: [AppInfo] = [
    AppInfo(name: "Bambu Studio",       fileName: "BambuStudio.dmg",    urlString: "GITHUB_LATEST"),
    AppInfo(name: "Brave Browser",      fileName: "BraveBrowser.dmg",   urlString: "https://referrals.brave.com/latest/Brave-Browser-arm64.dmg"),
    AppInfo(name: "Google Chrome",      fileName: "GoogleChrome.dmg",   urlString: "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"),
    AppInfo(name: "ChatGPT",            fileName: "ChatGPT.dmg",       urlString: "https://persistent.oaistatic.com/sidekick/public/ChatGPT_Desktop_public_latest.dmg"),
    AppInfo(name: "Grammarly Desktop",  fileName: "Grammarly.dmg",     urlString: "https://download-mac.grammarly.com/Grammarly.dmg"),
    AppInfo(name: "Visual Studio Code", fileName: "VSCode-arm64.zip",  urlString: "https://update.code.visualstudio.com/latest/darwin-arm64/stable"),
]

// ── Download Item Model ─────────────────────────────────

class DownloadItem: Identifiable, ObservableObject {
    let id = UUID()
    let name: String
    let fileName: String
    var resolvedURL: URL?

    enum Status {
        case queued
        case resolving
        case downloading
        case completed
        case failed(String)
    }

    @Published var status: Status = .queued
    @Published var progress: Double = 0.0
    @Published var bytesDownloaded: Int64 = 0
    @Published var totalBytes: Int64 = 0
    @Published var speedBytesPerSec: Double = 0
    @Published var etaSeconds: Double = -1

    var downloadStartTime: Date?

    init(name: String, fileName: String, url: URL?) {
        self.name = name
        self.fileName = fileName
        self.resolvedURL = url
    }

    var isCompleted: Bool {
        if case .completed = status { return true }
        return false
    }

    var isFailed: Bool {
        if case .failed = status { return true }
        return false
    }

    var isDownloading: Bool {
        if case .downloading = status { return true }
        return false
    }

    var sizeText: String {
        if bytesDownloaded == 0 && totalBytes == 0 { return "Waiting…" }
        let dl = formatBytes(bytesDownloaded)
        if totalBytes > 0 {
            let tot = formatBytes(totalBytes)
            return "\(dl) / \(tot)"
        }
        return dl
    }

    var speedText: String {
        guard speedBytesPerSec > 100 else { return "" }
        return "\(formatBytes(Int64(speedBytesPerSec)))/s"
    }

    var etaText: String {
        guard etaSeconds > 0 else { return "" }
        if etaSeconds < 60 {
            return "~\(Int(etaSeconds))s left"
        }
        let m = Int(etaSeconds) / 60
        let s = Int(etaSeconds) % 60
        return "~\(m)m \(s)s left"
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// ── Download Manager ────────────────────────────────────

class DownloadManager: NSObject, ObservableObject {
    @Published var items: [DownloadItem] = []
    @Published var allComplete = false
    @Published var overallStatus = "Preparing…"

    let batchSize = 5
    let destFolder: URL

    private var session: URLSession!
    private var taskToItem: [Int: DownloadItem] = [:]
    private var activeDownloads = 0
    private var pendingQueue: [DownloadItem] = []
    private var refreshTimer: Timer?

    override init() {
        self.destFolder = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        super.init()
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }

    func configure() {
        items = appDefinitions.map { info in
            let url = info.urlString == "GITHUB_LATEST" ? nil : URL(string: info.urlString)
            return DownloadItem(name: info.name, fileName: info.fileName, url: url)
        }
    }

    func startAll() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.objectWillChange.send()
        }
        resolveDynamicURLs { [weak self] in
            guard let self = self else { return }
            self.pendingQueue = self.items.filter { !$0.isFailed }
            self.overallStatus = "Downloading…"
            self.launchNextBatch()
        }
    }

    private func resolveDynamicURLs(completion: @escaping () -> Void) {
        let unresolved = items.filter { $0.resolvedURL == nil }
        guard !unresolved.isEmpty else { completion(); return }

        overallStatus = "Resolving latest versions…"
        for item in unresolved { item.status = .resolving }

        let apiURL = URL(string: "https://api.github.com/repos/bambulab/BambuStudio/releases/latest")!
        URLSession.shared.dataTask(with: apiURL) { data, _, _ in
            DispatchQueue.main.async {
                defer { completion() }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let assets = json["assets"] as? [[String: Any]] else {
                    for item in unresolved { item.status = .failed("Could not fetch release info") }
                    return
                }
                for asset in assets {
                    if let name = asset["name"] as? String,
                       name.lowercased().contains("mac"),
                       name.hasSuffix(".dmg"),
                       let urlStr = asset["browser_download_url"] as? String,
                       let url = URL(string: urlStr) {
                        for item in unresolved {
                            item.resolvedURL = url
                            item.status = .queued
                        }
                        return
                    }
                }
                for item in unresolved { item.status = .failed("No macOS DMG in release") }
            }
        }.resume()
    }

    private func launchNextBatch() {
        while activeDownloads < batchSize, !pendingQueue.isEmpty {
            let item = pendingQueue.removeFirst()
            guard let url = item.resolvedURL else {
                item.status = .failed("No URL")
                continue
            }
            item.status = .downloading
            item.downloadStartTime = Date()
            activeDownloads += 1

            let task = session.downloadTask(with: url)
            taskToItem[task.taskIdentifier] = item
            task.resume()
        }
        updateOverallStatus()
    }

    private func downloadFinished(item: DownloadItem) {
        activeDownloads -= 1
        launchNextBatch()
        if activeDownloads == 0 && pendingQueue.isEmpty {
            allComplete = true
            overallStatus = "All downloads complete!"
            refreshTimer?.invalidate()
            objectWillChange.send()
        }
    }

    private func updateOverallStatus() {
        let done = items.filter { $0.isCompleted }.count
        let failed = items.filter { $0.isFailed }.count
        let active = items.filter { $0.isDownloading }.count
        let queued = items.count - done - failed - active
        overallStatus = "\(done) done, \(active) downloading, \(queued) queued"
    }

    var overallProgress: Double {
        let total = Double(items.count)
        guard total > 0 else { return 0 }
        let value = items.reduce(0.0) { sum, item in
            if item.isCompleted || item.isFailed { return sum + 1.0 }
            if item.isDownloading { return sum + item.progress }
            return sum
        }
        return value / total
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard let item = taskToItem[downloadTask.taskIdentifier] else { return }

        item.bytesDownloaded = totalBytesWritten
        if totalBytesExpectedToWrite > 0 {
            item.totalBytes = totalBytesExpectedToWrite
            item.progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        }
        if let start = item.downloadStartTime {
            let elapsed = Date().timeIntervalSince(start)
            if elapsed > 1 {
                item.speedBytesPerSec = Double(totalBytesWritten) / elapsed
                if item.speedBytesPerSec > 0 && totalBytesExpectedToWrite > 0 {
                    item.etaSeconds = Double(totalBytesExpectedToWrite - totalBytesWritten) / item.speedBytesPerSec
                }
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let item = taskToItem[downloadTask.taskIdentifier] else { return }

        let dest = destFolder.appendingPathComponent(item.fileName)
        try? FileManager.default.removeItem(at: dest)
        do {
            try FileManager.default.moveItem(at: location, to: dest)
            item.status = .completed
            item.progress = 1.0
            if let attrs = try? FileManager.default.attributesOfItem(atPath: dest.path),
               let size = attrs[.size] as? Int64 {
                item.totalBytes = size
                item.bytesDownloaded = size
            }
        } catch {
            item.status = .failed(error.localizedDescription)
        }
        downloadFinished(item: item)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error,
              (error as NSError).code != NSURLErrorCancelled,
              let item = taskToItem[task.taskIdentifier] else { return }
        item.status = .failed(error.localizedDescription)
        downloadFinished(item: item)
    }
}

// ── SwiftUI Views ───────────────────────────────────────

struct ContentView: View {
    @ObservedObject var manager: DownloadManager

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Text("Download Apps")
                        .font(.title2.bold())
                    Spacer()
                    let done = manager.items.filter { $0.isCompleted }.count
                    Text("\(done) / \(manager.items.count)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                ProgressView(value: manager.overallProgress, total: 1.0)
                    .tint(.accentColor)
                HStack {
                    Text(manager.overallStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()

            Divider()

            // Download rows
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(manager.items) { item in
                        DownloadRowView(item: item)
                    }
                }
                .padding()
            }

            Divider()

            // Footer
            HStack {
                if manager.allComplete {
                    Button("Open Desktop") {
                        NSWorkspace.shared.open(manager.destFolder)
                    }
                }
                Spacer()
                if manager.allComplete {
                    Button("Done") { NSApp.terminate(nil) }
                        .keyboardShortcut(.defaultAction)
                } else {
                    Button("Cancel") { NSApp.terminate(nil) }
                        .keyboardShortcut(.cancelAction)
                }
            }
            .padding()
        }
        .frame(width: 560, height: 520)
    }
}

struct DownloadRowView: View {
    @ObservedObject var item: DownloadItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                statusIcon
                Text(item.name)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text(statusLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.12))
                    .clipShape(Capsule())
            }

            ProgressView(value: item.progress, total: 1.0)
                .tint(progressTint)

            HStack(spacing: 0) {
                Text(item.sizeText)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                if !item.speedText.isEmpty {
                    Text("  ·  ")
                        .foregroundColor(.secondary)
                    Text(item.speedText)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                if !item.etaText.isEmpty {
                    Text(item.etaText)
                        .font(.system(size: 11))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    @ViewBuilder
    var statusIcon: some View {
        switch item.status {
        case .queued:
            Image(systemName: "clock")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        case .resolving:
            ProgressView()
                .controlSize(.small)
        case .downloading:
            Image(systemName: "arrow.down.circle.fill")
                .foregroundColor(.blue)
                .font(.system(size: 14))
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 14))
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 14))
        }
    }

    var statusLabel: String {
        switch item.status {
        case .queued:       return "Queued"
        case .resolving:    return "Resolving…"
        case .downloading:  return "Downloading"
        case .completed:    return "Complete"
        case .failed:       return "Failed"
        }
    }

    var statusColor: Color {
        switch item.status {
        case .queued:       return .gray
        case .resolving:    return .orange
        case .downloading:  return .blue
        case .completed:    return .green
        case .failed:       return .red
        }
    }

    var progressTint: Color {
        switch item.status {
        case .completed:    return .green
        case .failed:       return .red
        case .downloading:  return .blue
        default:            return .gray
        }
    }

    var borderColor: Color {
        switch item.status {
        case .downloading:  return .blue.opacity(0.3)
        case .completed:    return .green.opacity(0.3)
        case .failed:       return .red.opacity(0.3)
        default:            return .gray.opacity(0.15)
        }
    }
}

// ── App Entry Point ─────────────────────────────────────

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let manager = DownloadManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        manager.configure()

        let contentView = ContentView(manager: manager)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 520),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Download Apps"
        window.contentView = NSHostingView(rootView: contentView)
        window.center()
        window.makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)

        manager.startAll()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
