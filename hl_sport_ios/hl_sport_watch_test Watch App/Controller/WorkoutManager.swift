/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The workout manager that interfaces with HealthKit.
*/

import Foundation
import HealthKit
import CoreLocation
import WatchKit
//import HealthKitUI

class WorkoutManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    
    //是否授权
//    @Published var isAuthed: Bool = false
    //断开重连
//    var reConnect = false
    //是否返回首页视图
    @Published var showHome: Bool = false
    //是否显示记录视图
    @Published var showRecord = true
    @Published var sharingDenied = false
    //是否显示运动中
//    @Published var showMetricsView = false
    @Published var showProgress = false

    //定位管理器
    let cllManager = CLLocationManager()
    //经纬度
//    @Published var longitude: Double = 0
//    @Published var latitude: Double = 0
    //水平信号
    @Published var cllAccuracy: Double = 0
    //蓝牙管理器
    @Published var btManger = BluetoothManager.shared

    //运动详细数据
    var details = [LiveData]()
    //上传的运动数据
    var uploadMoData: MotionData?
    //计时器
    var timer1: Timer?
    ///
    ///控制指令
    ///0：开始/继续；
    ///1：保存；
    ///2：删除；
    ///3：暂停；
    @Published var cTrol = 0
    //缓存数据
    @Published var showCache = false
    @Published var cacheData = [MotionData]()
    //电量
//    @Published var batteryLevel: Float = 0.0
//    @Published var devName = ""
    //距离单位
    @Published var distanceUnit = "m"
//    @Published var distanceUnitStr = "米"

    //单例实例
    private static let instance = WorkoutManager()
    //共有静态属性
    static let shared = instance
    //上传状态
    var isUploading = false
    
    private override init() {
        super.init()
        
//        let healthDataTypes: Set = [
//                     HKQuantityType.workoutType(),
//                     HKQuantityType(.heartRate),
//                     HKQuantityType(.activeEnergyBurned),
//                     HKQuantityType(.basalEnergyBurned),
//                     HKQuantityType(.distanceWalkingRunning),
//                     HKQuantityType(.stepCount)
//                 ]
//        healthDataAccessRequest(store: HealthKit.HKHealthStore, objectType: HKObjectType.workoutType(), doubleValue: 1), predicate: nil, trigger: nil) { Result<Bool, any Error> in
//        }
//        isAuthed = (healthStore.authorizationStatus(for: .workoutType()) == .sharingAuthorized)
//        selectedWorkout = .swimming
        //查询缓存和同步游泳数据
//        if UserDefaults.standard.bool(forKey: "HL_PhoneConfigured") {
//            syncSwimData(upload: true)
//        }
//        let usesMetricSystem = UserDefaults.standard.bool(forKey: "AppleMetrics")
//        print(usesMetricSystem ? "公制" : "非公制")
//        NotificationCenter.default.addObserver(self, selector: #selector(getMeasureUnit), name: NSNotification.Name.HKUserPreferencesDidChange, object: nil)

//        let authStatus = healthStore.authorizationStatus(for: .workoutType())
//        if authStatus == .notDetermined {
//            return
//        }
        //指定更新频率
//        healthStore.enableBackgroundDelivery(for: HKQuantityType(.distanceSwimming), frequency: HKUpdateFrequency.immediate) { success, error in
//            if success {
//                print("update frequency1 成功")
//            }
//            if (error != nil) {
//                print(error!.localizedDescription)
//            }
//        }
        
//        healthStore.enableBackgroundDelivery(for: HKQuantityType(.swimmingStrokeCount), frequency: HKUpdateFrequency.immediate) { success, error in
//            if success {
//                print("update frequency1 成功")
//            }
//            if (error != nil) {
//                print(error!.localizedDescription)
//            }
//        }
        
//        healthStore.enableBackgroundDelivery(for: HKQuantityType(.activeEnergyBurned), frequency: .immediate) { success, error in
//            if success {
//                print("update frequency2 成功")
//            }
//            if (error != nil) {
//                print(error!.localizedDescription)
//            }
//        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: WKApplication.didEnterBackgroundNotification, object: nil)
        //监听单位变化
        NotificationCenter.default.addObserver(self, selector: #selector(userPreferencesDidChange), name: NSNotification.Name.HKUserPreferencesDidChange, object: nil)
//        print("------设备型号-------")
//        print(HKDevice.local().model ?? "")
    }
    
    //单位变化
    @objc func userPreferencesDidChange() {
        getMeasureUnit()
    }
    
    @objc func applicationWillResignActive() {
        if timer1 != nil {
            //发送删除指令
            btManger.sendDataInstruct(ctrl: 2, hr: model.heartRate, time: model.timestamp, distance: Int(model.distance), kcal: Int(model.calorie), pace: model.pace)
        }
    }
    
    //获取测量单位
    func getMeasureUnit() {
        
//        let unitInfo = try await self.healthStore.preferredUnits(for: [HKQuantityType(.distanceSwimming)])
        healthStore.preferredUnits(for: [HKQuantityType(.distanceSwimming)]) { [weak self] unitInfo, error in
            if error == nil {
                let unit = unitInfo[HKQuantityType(.distanceSwimming)]
    //            print("游泳距离单位：\(unit?.unitString ?? "")")
                self?.distanceUnit = unit?.unitString ?? ""
    //            self?.distanceUnitStr = (self?.distanceUnit == "yd" ? "码" : "米")
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    //子线程查询缓存并上传数据
    func syncSwimData(upload: Bool=false) {
        if self.isUploading {
            return
        }

//        let task = DispatchWorkItem {
            print("-----------缓存数据上传--------------")
            //查询运动缓存数据
            if let data = CacheManager.shared.getUserData() {
                let hasCache = data.data.count>0
                DispatchQueue.main.async {
                    self.cacheData = data.data
                    self.showCache = hasCache
                    
                    //上传一次数据
                    if upload || hasCache {
                        var dones = 0
                        data.data.forEach { item in
                            NetworkManager.shared.saveSwimData(info: item, cache: true, complete: { info in
                                self.isUploading = true

                                self.cacheData = info
                                self.showCache = info.count>0
                                
                                dones += 1
                                if dones == data.data.count {
                                    self.isUploading = false
                                }
                            })
                        }
                    }
                }
            }
//        }

//        //后台异步执行一次性任务
//        DispatchQueue.global(qos: .background).async(execute: task)
//        //完成后主线程回调
//        task.notify(queue: .main) {
//            print("执行任务完成")
//        }
    }
    
    //低电量自动上传数据 10秒执行一次
    func lowBatteryAutoUpload() {
        let device = WKInterfaceDevice.current()
//        let w = device.screenBounds.width
//        print("屏幕宽度：\(w)")
        //启动电池监控
        device.isBatteryMonitoringEnabled = true
//        print("电量---\(device.batteryLevel)")
//        self.batteryLevel = device.batteryLevel
//        print("电池状态---\(device.batteryState.rawValue)")
        //手机型号
//        devName = device.name

        //获取电池电量
        if device.batteryLevel <= 0.01 {
            //结束运动
            endWorkout()
        }
    }
    
    func getPreferredDistanceUnit() -> String {
        let locale = Locale.current
        let distanceFormatter = MeasurementFormatter()
        distanceFormatter.unitOptions = .providedUnit
        distanceFormatter.numberFormatter.locale = locale
        
        let measurement = Measurement(value: 1, unit: UnitLength.meters)
        let formattedString = distanceFormatter.string(from: measurement)

        // 从格式化字符串中提取单位
//        let unitRange = formattedString.range(of: " ")
//        if unitRange.location != NSNotFound {
//            let unitString = String(formattedString[unitRange.location...])
//            return unitString
//        }
        return formattedString
        // 如果没有找到单位，则默认使用米
//        return "m"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //获取用户的真实方向 -0度位北
//        print("方向：\(newHeading.trueHeading)")
//        print("X:\(newHeading.x),Y:\(newHeading.y),Z:\(newHeading.z)")
    }

    //开始经纬度
//    var startCll: CLLocation?
    var locats: [CLLocation] = []
    //存储有效点位
    var locations: [CLLocation] = []
    //有效点位的定位
    var currenLocationIndex = 0
    //之前的游泳距离
    var oldLocationDistance = 0.0
    //之前的健康游泳距离
    var oldHealthDistance = 0.0

    
    //清理定位数据
    func clearLocationdata()  {
        locations.removeAll()
        locats.removeAll()
        currenLocationIndex = 0
        oldLocationDistance = 0.0
        oldHealthDistance = 0.0
    }
    

    @Published var totalDistance: CLLocationDistance = 0.0
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locats.append(contentsOf: locations)
        
        
    /*  蓝牙辅助定位显示代码 */
        
        if self.locats.count >= 3{
//            print("获取到的速度\(String(describing: self.locations.last?.speed) )")
//            print("获取到的时间\(String(describing: self.locations.last?.timestamp) )")
            let lastLoc = self.locats.last!
            let count =  self.locats.count
            var lastLoc2 = self.locats[count - 2]
            var lastLoc3 = self.locats[count - 3]
            
            //如果有有效数据用有效数据比较
            if locations.count >= 2{
                let locatCount =  self.locations.count
                lastLoc2 = self.locations.last!
                lastLoc3 = self.locations[locatCount - 1]

            }

            //距离
            let distance = lastLoc2.distance(from: lastLoc)
            let distanc2 = lastLoc3.distance(from: lastLoc2)

//            print("获取到的距离\(distance )")

            //时间
            let time = lastLoc.timestamp.timeIntervalSince1970 - lastLoc2.timestamp.timeIntervalSince1970
            let time2 = lastLoc2.timestamp.timeIntervalSince1970 - lastLoc3.timestamp.timeIntervalSince1970

//            print("获取到的时间\(time)")
            

            //速度
            let speed1 = distance/time
            let speed2 = distanc2/time2

//            print("获取到的时间speed\(speed1)")

            //加速度
            let acc = (speed1 - speed2)/time
//            print("获取到加速度acc\(acc)")
            
            //加速度小于0，03为有效值,速度小于8m/s
            if  abs(acc) <= 0.03 && speed1 < 8 {
                self.locations.append(self.locats.last!)
                
                // 计算并累加距离
                var  tempDistance = 0.0
                if self.locations.count > 1 {
                    for i in currenLocationIndex..<self.locations.count-1 {
                        let distance = self.locations[i].distance(from: self.locations[i + 1])
                        tempDistance += distance
                    }
                }

//                print("获取到currenLocationIndex\(currenLocationIndex)")
                
                //添加系数防止距离增加过快
                tempDistance =  tempDistance * 0.50

                //在游泳中更新数据
                if  running == true{
                    
                    //百米配速计算
                    let speed100 = time/distance*100.0
                    //配速不要太大
                    if speed100 < 5940{
                        self.speed = speed100
                    }else{
                        self.speed = 5940
                    }
                    //距离是0时候瞬时速度给0
                    if self.locations.count <= 1{
                        self.speed = 0
                    }
                    print("距离更新1\(self.distance )")
                    //平滑累计数据
                    self.distance = tempDistance + oldLocationDistance
                    model.distance = self.distance
                    self.dataSource = "GPS"
                }

            }
            
//            print("获取到的点位数量\(self.locations.count)")


        }

        
        
        // 计算并累加距离
        totalDistance = 0
        if self.locats.count > 0 {
            for i in 1..<self.locats.count {
                let distance = self.locats[i - 1].distance(from: self.locats[i])
                totalDistance += distance
            }
        }
        // 打印当前总距离
        print("Total walking distance: \(totalDistance) meters")
//        if distance == 0 && totalDistance>0 {
//            self.distance = totalDistance
//            model.distance = self.distance
//        }
        //获取经纬度
        if let location = locations.last {
//            if startCll == nil {
//                startCll = location
//            }
            //计算距离
//            if startCll != nil {
//            let dist = location.distance(from: startCll!)
//                if dist < 10 {
//                    self.distance += dist
//                    model.distance = self.distance
//                }
//            }
//            startCll = location
            
//            longitude = location.coordinate.longitude
//            latitude = location.coordinate.latitude
            //GPS信号
            cllAccuracy = location.horizontalAccuracy
            //海拔高度
//            print("海拔：\(location.altitude)")
            
            //停止定位
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("定位失败：\(error.localizedDescription)")
        //重新定位
        cllManager.requestLocation()
    }
    
    func initCLL() {
//        devName = "cll"
        //定位精度
        cllManager.desiredAccuracy = kCLLocationAccuracyBest
        //更新距离
        cllManager.distanceFilter = 1
        cllManager.delegate = self
        //定位权限
        if cllManager.authorizationStatus == .authorizedAlways || cllManager.authorizationStatus == .authorizedWhenInUse {
            //请求定位
            cllManager.requestLocation()
        } else {
//            cllManager.requestAlwaysAuthorization()
            cllManager.requestWhenInUseAuthorization()
        }
//        cllManager.stopUpdatingLocation()

        cllManager.allowsBackgroundLocationUpdates = true
        //开启定位服务
        cllManager.startUpdatingLocation()
        //开启方向服务
//        cllManager.startUpdatingHeading()
//        if CLLocationManager.locationServicesEnabled() {
//        } else {
//            print("没有定位服务")
//        }
    }

    //开启定位服务
    func startLocation() {
        cllManager.startUpdatingLocation()
    }
    
    //停止定位服务
    func stopLocation() {
        cllManager.stopUpdatingLocation()
    }
    
    var selectedWorkout: HKWorkoutActivityType? {
        didSet {
            guard let selectedWorkout = selectedWorkout else { return }
            startWorkout(workoutType: selectedWorkout)
        }
    }

    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }

    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

    //上分钟划水次数
    var lastStrokes = 0
    
    //停止定时器
    func stopWorkOut()  {
        timer1?.invalidate()
    }
    
    // Start the workout.
    func startWorkout(workoutType: HKWorkoutActivityType) {

        //清理定位数据
        clearLocationdata()
        
        let configuration = HKWorkoutConfiguration()
//        if #available(watchOS 10.0, *) {
//            configuration.activityType = .underwaterDiving
//        }
        
        configuration.activityType = workoutType
        
        if workoutType == .swimming {
            
            //开放水域游泳
            configuration.swimmingLocationType = .openWater
            configuration.locationType = .outdoor
            //泳池游泳
//            configuration.swimmingLocationType = .pool
//            configuration.locationType = .indoor
//            configuration.lapLength = HKQuantity(unit: HKUnit.meter(), doubleValue: 25)
        } else {
            
            //户外
            configuration.locationType = .outdoor
        }
        // Create the session and obtain the workout builder.
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            // Handle any exceptions.
            return
        }
        
        // Setup session and builder.
        session?.delegate = self
        builder?.delegate = self
        // Set the workout builder's data source.
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        //添加元数据
//        let metadata: [String: Any] = [
//            HKMetadataKeySwimmingStrokeStyle: HKSwimmingStrokeStyle.freestyle
//        ]
//        builder?.updateActivity(uuid: UUID(), adding: metadata, completion: { success, error in
//            if success {
//                print("添加元数据成功")
//            } else {
//                print(error!.localizedDescription)
//            }
//        })
        
        // Start the workout session and begin data collection.
        let startDate = Date()
//        session?.prepare()
        session?.startActivity(with: startDate)
//        if #available(watchOS 10.0, *) {
//            session?.startMirroringToCompanionDevice(completion: { success, error in
//            })
//        } else {
//            // Fallback on earlier versions
//        }
//        let config = HKWorkoutConfiguration()
//        config.activityType = .walking
//        session?.beginNewActivity(configuration: config, date: Date(), metadata: nil)
//        builder?.addWorkoutActivity(HKWorkoutActivity(workoutConfiguration: config, start: Date(), end: nil, metadata: nil), completion: { success, error in
//            if success {
//                print("addWorkoutActivity success")
//            } else {
//                print(error?.localizedDescription ?? "")
//            }
//        })
//        session?.currentActivity
//        builder?.workoutActivities
        self.btManger.showConnect = true
        //入水锁定
        WKInterfaceDevice.current().enableWaterLock()

        builder?.beginCollection(withStart: startDate) { (success, error) in
            // The workout has started.
//            print(error?.localizedDescription)
            if error == nil {
                DispatchQueue.main.async {
//                    device.waterResistanceRating //防水等级
//                    WKInterfaceDevice.current().play(WKHapticType.click)
//                    WKInterfaceDevice.current().crownOrientation //表冠方向
//                    WKInterfaceDevice.current().wristLocation //操作位置
                    
                    self.running = true
                }
            }
        }

//        builder?.seriesBuilder(for: HKSeriesType.heartbeat())
        //更新结束时间和uuid
//        builder?.updateActivity(uuid: UUID(), end: Date(), completion: { success, error in
//            if error != nil {
//                print(error!.localizedDescription)
//            }
//        })
        
 
        
        //查询设备信息指令 -改为暂停指令3
//        btManger.sendDeviceInstruct()
//        btManger.sendDataInstruct(ctrl: 3, hr: model.heartRate, time: Int(dist), distance: Int(self.distance), kcal: Int(model.calorie), pace: model.pace)
//        var sending = false
        //数据清零
        model = LiveData()
        model.zero()
        details = [LiveData]()
//        distance = 0
        cTrol = 0
        dist = 0
        distance = 0
        speed = 0
        strokeRates = []
        lastStrokes = 0
//        if timer != nil {
//            timer?.invalidate()
//            timer = nil
//        }
//        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
        timer1 = Timer(timeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
//            print(dist)
//            if cTrol != 3 {
            dist += 1
//            }
            //当前时间
            let elapsedTime = builder?.elapsedTime ?? 0
//            print("\(elapsedTime)#########################")
            //            if model.distance == 0 && dist > 2 {
            //                model.distance = dist
            //                self.distance = dist
            //            }
            //            if self.speed == 0 {
            if builder != nil && cTrol != 1 && cTrol != 2 {
                //计算百米配速 100m/s
//                if self.distance > 0 {
//                    let speed100 = elapsedTime/self.distance*100.0
//                    self.speed = speed100
//                    model.pace = Int(speed100)
//                    if model.pace/60 > 99 {
//                        self.speed = Double(99*60+(model.pace%60))
//                        model.pace = Int(speed100)
//                    }
//                }
                
                //在暂停时候配速显示0
                if self.running{
                    model.pace = Int(self.speed)
                }else{
                    model.pace = 0
                }
                

                //计算每分钟划水次数
                let times = Int(elapsedTime)%60
                if times == 0 && elapsedTime>0 {
                    let mintimes = model.strokeTimes-lastStrokes
//                    print("---------\(mintimes)次/分-------")
                    strokeRates.append(mintimes)
                    lastStrokes = model.strokeTimes
                } else {
                    //结束后不足一分钟计算
                }
                
            
                
                
                let item = LiveData(distance: model.distance, heartRate: model.heartRate, calorie: model.calorie, pace: model.pace, strokeTimes: model.strokeTimes,source: self.dataSource)
                self.details.append(item)
//                self.model.zero()
            }
            //数据下发指令
            if btManger.isConnect {
                //运动中发指令
                var heartRate = model.heartRate
                if self.cTrol == 1 || self.cTrol == 2 {
                    //平均心率
                    heartRate = Int(self.averageHeartRate.rounded())
                }
                btManger.sendDataInstruct(ctrl: cTrol, hr: heartRate, time: Int(elapsedTime), distance: Int(model.distance), kcal: Int(model.calorie), pace: model.pace)
            } else {
                //断开连接泳镜
//                reConnect = true
                //断开蓝牙连接
//                BluetoothManager.shared.isConnect = false
                //保存/删除
                if self.cTrol == 1 || self.cTrol == 2 {
                    //断开后停止计时器
                    timer.invalidate()
                    self.timer1 = nil
                    if self.cTrol == 2 {
                        resetWorkout()
                    }
                    return
                } else {
                    //断开后每5秒扫描一次，获取断连时间
                    if Int(dist) % 5 == 0 {
                        btManger.scanForPeripheral()
                    }
                    //断开重连
//                    btManger.reconnperipheral()
                }
            }
            if Int(dist) % 10 == 0 {
                //检测电量和上传数据
                lowBatteryAutoUpload()
//                getmovetime()
                //更新活动状态获取距离
//                if session != nil {
//                    session?.pause()
//                    session?.resume()
//                do {
//                    try 
//                    builder?.addWorkoutEvents([HKWorkoutEvent(type: HKWorkoutEventType.pause, dateInterval: DateInterval(start: Date(), duration: 1), metadata: nil)], completion: { success, error in
//                        if success {
//                            print("addWorkoutEvents success")
//                        } else {
//                            print(error?.localizedDescription ?? "")
//                        }
//                    })
//                } catch {
//                    print(error.localizedDescription)
//                }
//                }
            }
//            if Int(dist) % 5 == 0 {
                //查询游泳距离数据
//                getDistanceSwim(startDate: startDate)
//            }
//            sending = true
            //            }
        }
        RunLoop.main.add(timer1!, forMode: RunLoop.Mode.common)
    }

    func getDeviceInformation(device: HKDevice?) -> [String: String?]? {
        if (device == nil) {
            return nil;
        }
        
        let deviceInformation: [String: String?] = [
            "name": device?.name,
            "model": device?.model,
            "manufacturer": device?.manufacturer,
            "hardwareVersion": device?.hardwareVersion,
            "softwareVersion": device?.softwareVersion,
        ]
                
        return deviceInformation;
    }

    //授权
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.swimmingStrokeCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.distanceSwimming)
        ]

        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
//            HKQuantityType(.basalEnergyBurned),
            HKQuantityType(.swimmingStrokeCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.distanceSwimming),
//            HKQuantityType(.walkingSpeed),
//            HKQuantityType(.runningSpeed),
            HKQuantityType(.appleExerciseTime),
            HKQuantityType(.appleMoveTime),
//            HKQuantityType(.appleStandTime),
            HKQuantityType.workoutType(),
            HKObjectType.activitySummaryType()
        ]
        
        sharingDenied = false
        typesToShare.forEach { type in
            if healthStore.authorizationStatus(for: type) != .sharingAuthorized {
                sharingDenied = true
                return
            }
        }
        
        let authStatus = healthStore.authorizationStatus(for: .workoutType())
        if authStatus != .sharingAuthorized {
            print("无权限")
            sharingDenied = false
            
            // Request authorization for those quantity types.
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
                // Handle error.
                print(error?.localizedDescription ?? "")
            }
        }
    }

    // MARK: - Session State Control

    // The app's workout state.
    @Published var running = false

    func togglePause() {
        if running == true {
            pause()
        } else {
            resume()
        }
//        running = !running
        
//        timer?.fireDate = running ? .distantFuture : .distantFuture
        cTrol = running ? 0 : 3
    }

    //暂停
    func pause() {
        session?.pause()
        running = false
//        timer?.fireDate = Date.distantFuture
        cTrol = 3
        //提示音
        WKInterfaceDevice.current().play(WKHapticType.stop)
    }

    //继续
    func resume() {
        session?.resume()
        running = true
//        timer?.fireDate = Date.distantPast
        cTrol = 0
        
        print("距离更新3继续\(self.distance )")
        //继续更新定位的点位
        self.oldLocationDistance = self.distance
        self.currenLocationIndex =  (self.locations.count - 1) < 0 ? 0:(self.locations.count - 1)

        WKInterfaceDevice.current().play(WKHapticType.start)
    }

    //结束保存
    func endWorkout() {
        //保存
//        cTrol = 1
        session?.end()
//        showingSummaryView = true
        showProgress = true
    }
    
    //删除
    func delWorkout() {
        cTrol = 2
//        session?.end()
        DispatchQueue.main.async {
            self.showHome = true
            self.showRecord = true
        }
//        builder?.discardWorkout()
//        resetWorkout()
    }
    
    //查询运动时间
    func getmovetime() {
        //workout?.startDate
        queryMoveInfo(type: .appleExerciseTime, startDate: nil, endDate: Date()) { samples in
            if let mostRecentSample = samples.first as? HKQuantitySample {
                let quantity = mostRecentSample.quantity
                
                let seconds = quantity.doubleValue(for: HKUnit.second())
                let minutes = Int(seconds / 60)
                let formattedTime = String(format: "%02d:%02d", minutes / 60, minutes % 60)
                print("Total exercise time: \(formattedTime)")
//                let sam: HKSample?
//                if let sample = sam as? HKCategorySample {
//                    sample.value = HKCategoryValueSleepAnalysis.inBed.rawValue
//                    HKCategoryType(.heartburn)
//                }
                //查询设备信息
//                self.getDeviceInformation(device: mostRecentSample.device)
                
            } else {
                print("No exercise time samples found")
            }
        }
    }
   
    //查询游泳距离
    func getDistanceSwim(startDate: Date) {
        queryMoveInfo(type: .distanceSwimming, startDate: startDate, endDate: Date()) { samples in
            let distUnit = self.distanceUnit == "m" ? HKUnit.meter() : .yard()
//            self.distance = statistics.sumQuantity()?.doubleValue(for: distUnit) ?? 0
//            if let mostRecentSample = samples.first as? HKQuantitySample {
            var swimdistance = 0.0
            samples.forEach { sample in
                if let samp = sample as? HKQuantitySample {
                    swimdistance += samp.quantity.doubleValue(for: distUnit)
                }
            }
            print("Total distanceSwimming: \(swimdistance)")
//            self.distance = swimdistance
//            self.model.distance = swimdistance
        }
    }
    
    //查询泳姿
    func getswimstyle() {
//        let query = HKSampleQuery(sampleType: HKQuantityType.workoutType(), predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
//            if let error = error {
//                // 处理查询错误
//                print(error.localizedDescription)
//            }
//            if let results = results {
//                // 处理查询结果
//                for sample in results {
//                    if let workout = sample as? HKWorkout {
//                        // 检查泳姿元数据
//                        if let metadata = workout.metadata,
//                           let swimmingStyle = metadata[HKMetadataKeySwimmingStrokeStyle] as? Int {
//                            let strokeStyle = HKSwimmingStrokeStyle(rawValue: swimmingStyle)
//                            print("泳姿: \(swimmingStyle)")
//                        }
//                    }
//                }
//            }
//        }
//        let predicate = NSPredicate(format: "%K == %d", HKSampleTypeIdentifier.swimmingStrokeStyle, HKSwimmingStrokeStyle.freestyle.rawValue)
//        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        let query = HKAnchoredObjectQuery(type: HKCategoryType.workoutType(), predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
            // 处理查询结果
            if let error = error {
                print(error.localizedDescription)
            } else {
//                print(samples ?? "")
                guard let results = samples else { return }
                // 处理查询结果
                for sample in results {
                    if let workout = sample as? HKWorkout {
                        // 检查泳姿元数据
                        if let metadata = workout.metadata,
                           let swimmingStyle = metadata[HKMetadataKeySwimmingStrokeStyle] as? Int {
                            let strokeStyle = HKSwimmingStrokeStyle(rawValue: swimmingStyle)
                            print("泳姿: \(swimmingStyle)")
                        }
                    }
                }
            }
        }
        // 执行查询
        healthStore.execute(query)
//        let predicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeySwimmingStrokeStyle, allowedValues: [HKSwimmingStrokeStyle.freestyle.rawValue])
        // 创建查询来检索具有特定泳姿的锻炼样本
//        let query = HKSampleQuery(sampleType: HKPrescriptionType.workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
//            if let error = error {
//                print("查询错误: \(error.localizedDescription)")
//                return
//            }
//            // 处理查询结果
//            if let samples = results {
//                for sample in samples {
//                    if let workout = sample as? HKWorkout {
//                        // 获取泳姿元数据
//                        if let metadata = workout.metadata,
//                           let swimmingStyle = metadata[HKMetadataKeySwimmingStrokeStyle] as? Int {
//                            print("泳姿: \(HKSwimmingStrokeStyle(rawValue: swimmingStyle))")
//                        }
//                    }
//                }
//            }
//        }
    }
    
    //查询运动数据
    func queryMoveInfo(type: HKQuantityTypeIdentifier, startDate: Date?, endDate: Date?, result: @escaping(([HKSample])->Void)) {
        let quanType = HKQuantityType(type)
//        HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeySwimmingStrokeStyle)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
//        let query1 = HKQuantitySeriesSampleQuery(quantityType: HKQuantityType(type), predicate: predicate) { query, quantity, date, samples, success, error in
//            guard let samples = samples, error == nil else {
//                // Handle any errors
//                print("Error retrieving samples: \(String(describing: error))")
//                return
//            }
//        }
//        healthStore.execute(query1)
//        let predicate1 = HKSampleQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
//        HKQuantitySeriesSampleQueryDescriptor(predicate: nil, options: .includeSample)
        let query = HKSampleQuery(sampleType: quanType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            guard let samples = samples, error == nil else {
                // Handle any errors
                print("Error retrieving samples: \(String(describing: error))")
                return
            }
            result(samples)
        }
        healthStore.execute(query)
    }
    
    //获取运动数据汇总上传
    func postMotionData() {
        //运动结果数据
        guard let wt = workout else { return }
        
        let data = MotionData()
        data.detailList = details
        data.totalDurationTime = Int(wt.duration)
//        data.totalDurationTime = Int(self.exercisetime)
        data.startTime = wt.startDate.toYmdHms()
        data.startTimestamp = Int(wt.startDate.timeIntervalSince1970)
        data.endTime = wt.endDate.toYmdHms()
        data.endTimestamp = Int(wt.endDate.timeIntervalSince1970)
        let distUnit = self.distanceUnit == "m" ? HKUnit.meter() : .yard()
        data.totalDistance = wt.totalDistance?.doubleValue(for: distUnit) ?? 0
//        data.totalDistance = self.distance
        data.lengthUnit = (distanceUnit == "m" ? 1 : 2)
//        data.averageSpeed = averageSpeed
        data.totalCalorie = wt.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
        data.averageHeartRate = Int(self.averageHeartRate.rounded())
        data.totalStrokeTimes = Int(self.model.strokeTimes)
        //追加最后距离配速数据
        if data.totalDistance > 0 {
            let averageSpeed = Int(wt.duration/data.totalDistance*100)
            data.detailList?.append(LiveData(distance: data.totalDistance, heartRate: model.heartRate, calorie: data.totalCalorie, pace: averageSpeed, strokeTimes: data.totalStrokeTimes,source: self.dataSource))
        }
        //划水频率
        //结束后不足一分钟计算
        if model.strokeTimes>0 {
            let mintimes = model.strokeTimes-lastStrokes
            let times = Int(wt.duration)%60
            if mintimes>0 && times>0 {
                strokeRates.append(Int(Double(mintimes)/Double(times)*60.0))
            }
        }
//        print(strokeRates)
        data.maxStrokeRate = strokeRates.max() ?? 0
        //计算平均值
        if strokeRates.count > 0 {
            data.averageStrokeRate = strokeRates.reduce(0, +)/strokeRates.count
        }
//        data.totalStrokeTimes = Int(strokes == 0 ? dist-1 : strokes)
        data.strokeType = "MX"
//        wt.allStatistics[HKQuantityType(.appleExerciseTime)]
//        wt.hasUndeterminedDuration
        //获取泳姿 HKAverageMETs: 2.1 kcal/kg·hr
        if let mdata = workout?.metadata {
            if let style = mdata[HKMetadataKeySwimmingStrokeStyle] as? String {
                data.strokeType = style
            }
        } else {
            // 计算每划行进的距离
            let strokes = wt.totalSwimmingStrokeCount?.doubleValue(for: .count()) ?? 0
            let distancePerStroke = data.totalDistance / strokes
            // 根据距离/划水次数识别泳姿
            data.strokeType = "K"
            switch distancePerStroke {
            case 1...2:
                print("蛙泳")
                data.strokeType = "BR"
            case 2...3:
                print("自由泳")
                data.strokeType = "FR"
            case 3...4:
                print("仰泳")
                data.strokeType = "BK"
            case 4...:
                print("蝶泳")
                data.strokeType = "BT"
            default:
                print("泳姿识别不清")
                data.strokeType = "P"
            }

        }
//        print(data.mj_JSONString())
        //上传数据
        NetworkManager.shared.saveSwimData(info: data, complete: nil)
        
        //缓存未上传数据
        uploadMoData = data
    }

    //缓存未上传的运动数据
    func cacheMotionData() {
        guard let data = uploadMoData else { return }
        //子线程缓存数据
        DispatchQueue.global(qos: .background).async {
            CacheManager.shared.saveWorkoutData(model: data, complete: { data in
                DispatchQueue.main.async {
                    //回到主线程
                    self.cacheData = data
                    self.showCache = true
                }
            })
            //保存后查询数据
//            if let data = CacheManager().getUserData() {}
        }
    }
    
    // MARK: - Workout Metrics
    @Published var exercisetime: Double = 0
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var speed: Double = 0
    //划水次数
    @Published var strokes: Double = 0
    //划水频率 次/分
    @Published var averageStrokeRate: Double = 0
    @Published var maxStrokeRate: Double = 0

    @Published var workout: HKWorkout?
    //初始化实时数据对象
    var model = LiveData()
    var dist = 0.0
    //划水次数频率数组 10秒/次 -次/分
    var strokeRates = [Int]()

    //数据来源，主要是距离
    var dataSource = "Apple Watch"

    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
                //心率
            case HKQuantityType(.heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.model.heartRate = Int(self.heartRate)
                //能量消耗  HKQuantityType(.physicalEffort):动态千卡
            case HKQuantityType(.activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
                self.model.calorie = self.activeEnergy
                //运动距离 .distanceWalkingRunning .distanceCycling
            case HKQuantityType(.distanceSwimming):
                let distUnit = self.distanceUnit == "m" ? HKUnit.meter() : .yard()

                print("距离更新2\(self.distance )")

                let healthSwimDistance =  statistics.sumQuantity()?.doubleValue(for: distUnit) ?? 0
                
                //判断是否是之前的旧数据防止数据会退
                if healthSwimDistance != self.oldHealthDistance{
                    
                    self.oldHealthDistance = healthSwimDistance
                    self.distance = healthSwimDistance
                    self.model.distance = self.distance
                    self.dataSource = "Apple Watch"
                    //清理定位获取到的数据
                    self.currenLocationIndex =  (self.locations.count - 1) < 0 ? 0:(self.locations.count - 1)
                    self.oldLocationDistance = self.distance
                    print("距离更新2健康\(self.distance )")

                    
                    //配速给值
                    let times = self.builder?.elapsedTime ?? 0
                    let speed100 =  times/self.distance*100.0
                    //配速不要太大
                    if speed100 < 5940{
                        self.speed = speed100
                    }else{
                        self.speed = 5940
                    }
                }
                
                
//            case HKQuantityType(.distanceWalkingRunning):
//                let distUnit = self.distanceUnit == "m" ? HKUnit.meter() : .yard()
//                self.distance = statistics.sumQuantity()?.doubleValue(for: distUnit) ?? 0
//                self.model.distance = self.distance
                //运动时间
            case HKQuantityType(.appleMoveTime), HKQuantityType(.appleExerciseTime):
                let times = statistics.sumQuantity()?.doubleValue(for: HKUnit.second()) ?? 0
                self.exercisetime = times
                print("运动时间：\(times)S")
//            case HKQuantityType(.walkingSpeed), HKQuantityType(.runningSpeed):
//                //百米配速 m/s
//                let distUnit = self.distanceUnit == "m" ? HKUnit.meter() : .yard()
//                self.speed = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.second().unitDivided(by: distUnit)) ?? 0
//                if self.speed == 0 {
//                    let times = self.builder?.elapsedTime ?? 0
//                    self.speed = times/self.distance*100.0
//                }
//                self.model.pace = Int(self.speed)
            case HKQuantityType(.swimmingStrokeCount):
                //划水次数 5秒获取一次
                self.strokes = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
//                print("划水总次数：\(self.strokes)")
                self.model.strokeTimes = Int(self.strokes)
                
            default:
                return
            }
        }
    }

    func resetWorkout() {
        selectedWorkout = nil
        builder = nil
        workout = nil
        session = nil
        activeEnergy = 0
        model.calorie = 0
        averageHeartRate = 0
        heartRate = 0
        model.heartRate = 0
        distance = 0
        model.distance = 0
        speed = 0
        model.pace = 0
//        speeds = [Double]()
        strokes = 0
        model.strokeTimes = 0
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didBegin workoutActivity: HKWorkoutActivity) {
        print("didBegin")
        //开始运动
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didEnd workoutActivity: HKWorkoutActivity) {
        print("didEnd")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        print("didGenerate")
        //暂停或继续产生事件
//        workoutSession.currentActivity.workoutEvents
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didDisconnectFromRemoteDeviceWithError error: (any Error)?) {
        print("didDisconnectFromRemoteDeviceWithError")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didReceiveDataFromRemoteWorkoutSession data: [Data]) {
        print("didReceiveDataFromRemoteWorkoutSession")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("didChange")
        DispatchQueue.main.async {
            self.running = toState == .running
        }

        // Wait for the session to transition states before ending the builder.
        if toState == .ended {
            //运动完成查询记录
            builder?.endCollection(withEnd: date) { (success, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                }
                self.builder?.finishWorkout { (workout, error) in
                    if error == nil {
                        self.workout = workout
                        //总距离
                        let distUnit = self.distanceUnit == "m" ? HKUnit.meter() : .yard()
                        self.distance = workout?.totalDistance?.doubleValue(for: distUnit) ?? 0
                        self.model.distance = self.distance
                        self.cTrol = 1
                        //保存游泳距离
//                        if let wt = workout {
//                            let distUnit = self.distanceUnit == "m" ? HKUnit.meter() : .yard()
//                            self.healthStore.save(HKQuantitySample(type: HKQuantityType(.distanceSwimming), quantity: HKQuantity(unit: distUnit, doubleValue: self.distance), start: wt.startDate, end: wt.endDate)) { success, error in
//                                if success {
//                                    print("游泳距离保存成功")
//                                }
//                            }
//                        }
                        DispatchQueue.main.async {
                            //缓存和上传数据
                            self.postMotionData()

                            self.showProgress = false
                            //返回
                            self.showHome = true
                            //结算
                            self.showingSummaryView = true
                            //查询运动时间
//                            self.getmovetime()
//                            self.getswimstyle()
                        }
                    } else {
                        //失败后删除返回
                        print(error!.localizedDescription)
                        self.delWorkout()
                    }
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("workoutSession fail: \(error.localizedDescription)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didBeginActivityWith workoutConfiguration: HKWorkoutConfiguration, date: Date) {
        print("运动开始\(date)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didEndActivityWith workoutConfiguration: HKWorkoutConfiguration, date: Date) {
        print("运动结束\(date)")
//        timer?.fireDate = .distantFuture
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        print("运动中")
    }

    //获取动态运动实时数据
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }

            let statistics = workoutBuilder.statistics(for: quantityType)
//            print(statistics?.quantityType)
            
            // Update the published values.
            updateForStatistics(statistics)
        }
    }
}

extension Double {
    //保留一位小数
    func decimal1() -> Double {
//        return roundl(self * 10.0) / 10.0
        if self <= 0 {
            return 0.0
        }
        return precision(len: 1)
    }
    
    func precision(len: Int) -> Double {
        let str = formatted(.number.precision(.fractionLength(len)))
        return Double(str) ?? 0
    }
}

extension Date {
    //转时间年月日时分秒
    func toYmdHms() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return format.string(from: self)
    }
}

extension String {
    
    //字典转json
    func toJson(dic: NSMutableDictionary) -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            
            if var json = String(data: data, encoding: .utf8) {
                //去掉空格和换行符
                json = json.replacingOccurrences(of: " ", with: "")
                json = json.replacingOccurrences(of: "\n", with: "")
                return json
            }
        } catch {
            print(error)
        }
        return ""
    }
    
    //json转字典
    func toDic() -> Any {
        var dic: Any?
        if let data = self.data(using: .utf8) {
            do {
                dic = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            } catch {
                print(error)
            }
        }
        if dic == nil {
            return ""
        }
        return dic!
    }
}
