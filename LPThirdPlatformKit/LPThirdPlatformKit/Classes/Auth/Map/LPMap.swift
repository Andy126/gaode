//
//  LPTAuthStravaProvider.swift
//  Action
//
//  Created by gl on 2023/6/7.
//

import AMapFoundationKit
import AMapLocationKit


public class LPMap: UIViewController{
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
       
        AMapServices.shared().apiKey = "46d6324d9cb9e82fa42e144c4d3f0408"
        AMapServices.shared().enableHTTPS = true
        
        //添加定位时会报错
        var locatopm = AMapLocationManager()
        
        view.backgroundColor = .red
        AMapServices.shared().enableHTTPS = true
    }
    
}




