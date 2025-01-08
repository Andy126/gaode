/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The elapsed time.
*/

import SwiftUI

struct ElapsedTimeView: View {
    var elapsedTime: TimeInterval = 0
    var showSubseconds: Bool = true
    
    @State private var timeFormatter = ElapsedTimeFormatter(showSubseconds: true)
//    var timeFormatter1 = ElapsedTimeFormatter(showHundredths: true)

    var body: some View {
        Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
//            .fontWeight(.semibold)
            .font(.system(size: 24, weight: .medium))
            .onChange(of: showSubseconds) {
                timeFormatter.showSubseconds = $0
            }
//        + Text(NSNumber(value: elapsedTime), formatter: timeFormatter1)
//            .font(.system(size: 16, weight: .medium))
//            .fontWeight(.regular)
    }
}

class ElapsedTimeFormatter: Formatter {
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var showSubseconds = false
    var showHundredths = false

    init(showSubseconds: Bool = false, showHundredths: Bool = false) {
        self.showSubseconds = showSubseconds
        self.showHundredths = showHundredths
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString? {
        guard let time = obj as? TimeInterval else {
            return nil
        }

        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }

        let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        
        return NSAttributedString(string: String(format: "%@%@%0.2d", formattedString, decimalSeparator, hundredths))
    }
    
    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }

        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }

        if showHundredths {
            let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%0.2d", decimalSeparator, hundredths)
        }
        
        if showSubseconds {
            
            let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%@%0.2d", formattedString, decimalSeparator, hundredths)
        }

        return formattedString
    }
}

struct ElapsedTime_Previews: PreviewProvider {
    static var previews: some View {
        ElapsedTimeView()
    }
}
