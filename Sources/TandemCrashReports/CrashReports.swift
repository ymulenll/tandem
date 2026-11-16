import Foundation
#if !DEBUG
import Sentry
#endif

/// Crash reporting stays disabled in Yoelvis’s personal fork.
/// No reports are sent to the upstream author's Sentry project.
public enum CrashReports {
    /// A Sentry DSN is a public client key; it ships inside the app anyway.
    static let dsn = ""

    /// `component` is `mac` for the app and `cli` for the `tandem` command,
    /// so the watcher can tell them apart.
    public static func start(component: String) {
        #if !DEBUG
        guard !dsn.isEmpty else { return }
        let bundle = Bundle.main
        guard shouldReport(bundleURL: bundle.bundleURL, environment: ProcessInfo.processInfo.environment) else { return }
        let release = releaseName(info: bundle.infoDictionary ?? [:])
        SentrySDK.start { options in
            options.dsn = dsn
            options.environment = "production"
            options.releaseName = release
            options.sendDefaultPii = false
            options.tracesSampleRate = 0
            options.enableAutoPerformanceTracing = false
            options.enableAutoSessionTracking = false
            // The app has its own main-thread meter, and Sentry's hang
            // reports are noisy on macOS while a long export or render runs.
            options.enableAppHangTracking = false
            // Swizzling is what adds network breadcrumbs (provider URLs can
            // carry search terms) and reports failed HTTP requests as
            // errors; neither belongs here.
            options.enableSwizzling = false
            options.enableNetworkBreadcrumbs = false
            options.enableCaptureFailedRequests = false
            options.sendClientReports = false
            // The app and the command share a bundle, so each gets its own
            // folder; otherwise the next `tandem` run could pick up the app's
            // crash report and send it tagged `cli`.
            options.cacheDirectoryPath = cacheDirectory(component: component).path
            options.beforeSend = { event in
                isBrokenPipe(event) ? nil : event
            }
            options.initialScope = { scope in
                scope.setTag(value: component, key: "component")
                return scope
            }
        }
        #endif
    }

    /// The installed release copy, and nothing an agent or a test is running.
    static func shouldReport(bundleURL: URL, environment: [String: String]) -> Bool {
        if NSClassFromString("XCTestCase") != nil || environment["XCTestConfigurationFilePath"] != nil { return false }
        if let ci = environment["CI"], !ci.isEmpty, ci != "0", ci.lowercased() != "false" { return false }
        return isInstalledApp(bundleURL: bundleURL, home: FileManager.default.homeDirectoryForCurrentUser)
    }

    /// Where `setup_mac.sh` puts the app (or /Applications, if Mike moves
    /// it there). The `tandem` command's main bundle is the app around it.
    static func isInstalledApp(bundleURL: URL, home: URL) -> Bool {
        let path = bundleURL.standardizedFileURL.resolvingSymlinksInPath().path
        let installed = [
            home.appendingPathComponent("Applications/Tandem.app").standardizedFileURL.resolvingSymlinksInPath().path,
            "/Applications/Tandem.app"
        ]
        return installed.contains(path)
    }

    /// `tandem@0.1.0+<commit>`: build-app.sh stamps the commit into the
    /// bundle's Info.plist as `TandemCommit`.
    static func releaseName(info: [String: Any]) -> String {
        let version = info["CFBundleShortVersionString"] as? String ?? "0"
        let commit = info["TandemCommit"] as? String ?? info["CFBundleVersion"] as? String ?? "unknown"
        return "tandem@\(version)+\(commit)"
    }

    static func cacheDirectory(component: String) -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("com.mikerosoft.tandem/sentry-\(component)", isDirectory: true)
    }

    #if !DEBUG
    /// `tandem watch | head` ends the command with SIGPIPE when head has
    /// read enough. Sentry counts that signal as a crash; it isn't one.
    static func isBrokenPipe(_ event: Event) -> Bool {
        guard let exception = event.exceptions?.first else { return false }
        if exception.type == "SIGPIPE" { return true }
        let signal = exception.mechanism?.meta?.signal
        return signal?["name"] as? String == "SIGPIPE" || signal?["number"] as? Int == Int(SIGPIPE)
    }
    #endif
}
