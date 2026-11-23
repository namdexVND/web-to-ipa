import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var reloadTrigger: Int
    @Binding var errorMessage: String?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if context.coordinator.lastReloadTrigger != reloadTrigger {
            context.coordinator.lastReloadTrigger = reloadTrigger
            errorMessage = nil
            uiView.load(URLRequest(url: url))
        }
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var lastReloadTrigger: Int = 0

        init(_ parent: WebView) {
            self.parent = parent
            self.lastReloadTrigger = parent.reloadTrigger
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.errorMessage = nil
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.errorMessage = error.localizedDescription
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.errorMessage = error.localizedDescription
        }
    }
}

struct ContentView: View {
    private let targetURL = URL(string: "https://motioncut.io.vn/")!
    @State private var reloadTrigger = 0
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            WebView(url: targetURL, reloadTrigger: $reloadTrigger, errorMessage: $errorMessage)
                .ignoresSafeArea()

            if let errorMessage = errorMessage {
                VStack(spacing: 14) {
                    Text("Không thể tải trang web")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Button("Thử tải lại") {
                        reloadTrigger += 1
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
    }
}

@main
struct WebAppMain: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
