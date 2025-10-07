import SwiftUI
import WebKit


class Oklhfhgshdjgf: ObservableObject {
    func pageDidLoad() {
            fsduguf = false
        }
    
    @Published var hbnnasdg: String = "newbva"
    @Published var fsduguf: Bool = true
    @Published var nsdih: Bool = false
    @Published var llsdfh: Bool = false
    @Published var yyyhsdh = UserDefaults.standard.bool(forKey: "brwsbsdf")
    @AppStorage("huijashgd") var huijashgd: Bool = true
    @AppStorage("nnsadvb") var nnsadvb: String = "dfbsdf"
    @Published var ytehdsfg: Bool = false
    @Published var wfsadf: WKWebView? = nil

}

struct Bvgdcs: View {

     enum NavigationAction {
           case fdghvcb(WKNavigationAction,  (WKNavigationActionPolicy) -> Void)
           case vxczsff(URLAuthenticationChallenge, (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
           case asdhbv(WKNavigation)
           case poiergh(WKNavigation)
           case bvchg(WKNavigation)
           case ghsvd(WKNavigation)
           case rtwegc(WKNavigation,Error)
           case jdhfg(WKNavigation,Error)
       }
       
    @ObservedObject var nsdhvg: Oklhfhgshdjgf
     
    private var actionDelegate: ((_ navigationAction: Bvgdcs.NavigationAction) -> Void)?
    let sdfgdfxvc: URLRequest
    var body: some View {
        
        ZStack{
          
            Nbxcnjvb(hwgvfbdsfbvweghjb: nsdhvg,
                           action: actionDelegate,
                            request: sdfgdfxvc).zIndex(99)
            ZStack{
                VStack{
                    HStack{
                        Button(action: {
                            
                                       nsdhvg.llsdfh = true
                                       nsdhvg.wfsadf?.removeFromSuperview()
                                       nsdhvg.wfsadf?.superview?.setNeedsLayout()
                                       nsdhvg.wfsadf?.superview?.layoutIfNeeded()
                                       nsdhvg.wfsadf = nil
                                       nsdhvg.ytehdsfg = false
                        }) {
                            
                            Image(systemName: "chevron.backward.circle.fill").resizable().frame(width: 20, height: 20).foregroundColor(.white)
                            
                        }.padding(.leading, 20).padding(.top, 15)
                        Spacer()
                    }
                    Spacer()
                }
            }.ignoresSafeArea()
        }.statusBarHidden(true)

        .onAppear(){
            AppDelegate.orientationLock = UIInterfaceOrientationMask.all
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
       
    }

    init(uRLRequest: URLRequest, webViewStateModel: Oklhfhgshdjgf) {
        self.sdfgdfxvc = uRLRequest
        self.nsdhvg = webViewStateModel
         
    }
    
    init(url: URL, webViewStateModel: Oklhfhgshdjgf) {
        self.init(uRLRequest: URLRequest(url: url),
                  webViewStateModel: webViewStateModel)
    }
    
    
}


struct Nbxcnjvb : UIViewRepresentable {
   
    @ObservedObject var twergdf: Oklhfhgshdjgf
    private var bcvxb: WKWebView?
    let hjgdfk: ((_ navigationAction: Bvgdcs.NavigationAction) -> Void)?
     let hdfjgv: URLRequest
  @State private var hgdfhvajhdfg: WKWebView?
    
    init(hwgvfbdsfbvweghjb: Oklhfhgshdjgf,
    action: ((_ navigationAction: Bvgdcs.NavigationAction) -> Void)?,
    request: URLRequest) {
        self.hjgdfk = action
        self.hdfjgv = request
        self.twergdf = hwgvfbdsfbvweghjb
        self.hgdfhvajhdfg = WKWebView()
        self.hgdfhvajhdfg?.backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)
        self.hgdfhvajhdfg?.scrollView.backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)
        self.hgdfhvajhdfg = WKWebView()
        self.hgdfhvajhdfg?.isOpaque = false
       
        
    }
   

    func makeUIView(context: Context) -> WKWebView  {
        var kjdfshg = WKWebView()
        let jksdhagf = WKPreferences()
        @ObservedObject var webViewStateModel: Oklhfhgshdjgf
        jksdhagf.javaScriptCanOpenWindowsAutomatically = true

        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.preferences = jksdhagf
        configuration.applicationNameForUserAgent = "Version/17.2 Mobile/15E148 Safari/604.1"
        kjdfshg = WKWebView(frame: .zero, configuration: configuration)
        kjdfshg.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        kjdfshg.navigationDelegate = context.coordinator
        kjdfshg.uiDelegate = context.coordinator
        kjdfshg.allowsBackForwardNavigationGestures = true
      

        kjdfshg.load(hdfjgv)
        
       

        return kjdfshg
    }
   
     func updateUIView(_ uiView: WKWebView, context: Context) {


         self.hgdfhvajhdfg = WKWebView()

        if uiView.canGoBack, twergdf.llsdfh {
            uiView.goBack()
            twergdf.llsdfh = false

        }


    }
    var onThirdRedirecttt: ((_ url: URL) -> Void)?
    func makeCoordinator() -> Coordinator {
           return Coordinator(parent: self, action: nil, webViewStateModel: self.twergdf)
       }

    final class Coordinator: NSObject {
        var popupWebView: WKWebView?
        var parent: Nbxcnjvb
        var redirectCounter = 0
        var redirectstring = ""
        
        
        var bheyewuhvviuehv: Oklhfhgshdjgf
        let action: ((_ navigationAction: Bvgdcs.NavigationAction) -> Void)?
        
        init(parent: Nbxcnjvb, action: ((_ navigationAction: Bvgdcs.NavigationAction) -> Void)?, webViewStateModel: Oklhfhgshdjgf) {
            self.parent = parent
            self.action = action
            self.bheyewuhvviuehv = webViewStateModel
            super.init()
        }
    }

}

extension Nbxcnjvb.Coordinator: WKNavigationDelegate, WKUIDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
    
                
                let response = navigationResponse.response as? HTTPURLResponse
                if let headers = response?.allHeaderFields as? [String: Any] {
                    print("Response Headers: \(headers)")
                }
                decisionHandler(.allow)
            }
 
        
    func webView(_ uyhdsfuygf: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        let jsCode = "var allLinks = document.getElementsByTagName('a');if (allLinks) { var i;for (i=0; i<allLinks.length; i++) {var link = allLinks[i];var target = link.getAttribute('target');if (target && target == '_blank') {link.setAttribute('target','_self');} } }"
        uyhdsfuygf.evaluateJavaScript(jsCode, completionHandler: nil)
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            uyhdsfuygf.load(navigationAction.request)
           decisionHandler(.cancel)
           return
        }
        
        if action == nil {
            decisionHandler(.allow)
        } else {
            action?(.fdghvcb(navigationAction, decisionHandler))
           
        }
        
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        action?(.asdhbv(navigation))
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        action?(.poiergh(navigation))
        if webView.url != nil {
                   
                }
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        bheyewuhvviuehv.fsduguf = false
        bheyewuhvviuehv.nsdih = webView.canGoBack
        action?(.rtwegc(navigation, error))
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        action?(.bvchg(navigation))
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame != true {
            
            let popupWebView = WKWebView(frame: webView.bounds, configuration: configuration)
            
            popupWebView.navigationDelegate = self
            
            popupWebView.uiDelegate = self
             
            webView.addSubview(popupWebView)
            webView.setNeedsLayout()
            webView.layoutIfNeeded()
           
            bheyewuhvviuehv.wfsadf = popupWebView
            
            bheyewuhvviuehv.ytehdsfg = true
            
            return popupWebView
        }
        return popupWebView
    }

    func webView(_ vgweubhdvhsdkv: WKWebView, didFinish navigation: WKNavigation!) {
        bheyewuhvviuehv.fsduguf = false
         
        bheyewuhvviuehv.yyyhsdh = true
        UserDefaults.standard.set(bheyewuhvviuehv.yyyhsdh, forKey: "brwsbsdf")
        
        vgweubhdvhsdkv.allowsBackForwardNavigationGestures = true
        bheyewuhvviuehv.nsdih = vgweubhdvhsdkv.canGoBack
        if let title = vgweubhdvhsdkv.title {
            bheyewuhvviuehv.hbnnasdg = title
        }
        
        vgweubhdvhsdkv.configuration.mediaTypesRequiringUserActionForPlayback = .all
        vgweubhdvhsdkv.configuration.allowsInlineMediaPlayback = false
        vgweubhdvhsdkv.configuration.allowsAirPlayForMediaPlayback = false
        action?(.ghsvd(navigation))
        
        guard let destinationUrl = vgweubhdvhsdkv.url?.absoluteURL.absoluteString else {
            
            return
        }
    
        var components = URLComponents(string: destinationUrl)!
        let cutUrl = components.url!.absoluteString
        
        if bheyewuhvviuehv.nnsadvb == "dfbsdf" && self.bheyewuhvviuehv.huijashgd{
                self.bheyewuhvviuehv.nnsadvb = components.url!.absoluteString
           
            
                self.bheyewuhvviuehv.huijashgd = false
                self.bheyewuhvviuehv.fsduguf = false

           
        } else {
            
        }

    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        bheyewuhvviuehv.fsduguf = false
        action?(.jdhfg(navigation, error))
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if action == nil  {
            completionHandler(.performDefaultHandling, nil)
        } else {
            action?(.vxczsff(challenge, completionHandler))
        }
        
    }
    
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            popupWebView?.removeFromSuperview()
            popupWebView = nil
        }
    }
    
}


