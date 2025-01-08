//
//  LPTAuthStravaProvider.swift
//  Action
//
//  Created by gl on 2023/6/7.
//

import AMapSearchKit
import MAMapKit

//import LPNetwork
//import Alamofire
//import AuthenticationServices
//import LPCommon

public class LPMap: UIViewController{
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
       
        AMapServices.shared().apiKey = "46d6324d9cb9e82fa42e144c4d3f0408"
        AMapServices.shared().enableHTTPS = true
        
        var search = AMapSearchAPI()
//        MAMapView.updatePrivacyShow(.didShow, privacyInfo: .didContain)
//        MAMapView.updatePrivacyAgree(.didAgree)
        
        view.backgroundColor = .red
        AMapServices.shared().enableHTTPS = true
        let mapView = MAMapView.init(frame: self.view.frame)
        mapView.showsUserLocation = true
        mapView.userTrackingMode =  .follow
        mapView.zoomLevel = 16
        
        view.addSubview(mapView)
    }
    
}




