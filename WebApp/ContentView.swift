import SwiftUI
import WebKit

@MainActor
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
        context.coordinator.parent = self
        if context.coordinator.lastReloadTrigger != reloadTrigger {
            context.coordinator.lastReloadTrigger = reloadTrigger
            DispatchQueue.main.async { errorMessage = nil }
            uiView.load(URLRequest(url: url))
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var lastReloadTrigger: Int

        init(_ parent: WebView) {
            self.parent = parent
            self.lastReloadTrigger = parent.reloadTrigger
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.errorMessage = nil
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            report(error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            report(error)
        }

        private func report(_ error: Error) {
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled { return } // bỏ qua lỗi hủy (-999)
            parent.errorMessage = error.localizedDescription
        }
    }
}
