//
//  LPModifyDataViewController.swift
//  LPMineModule
//
//  Created by 西柚 on 2022/11/24.
//

import UIKit
import LPUIKit
import LPNetwork
import LPCommon

// MAKR: 要修改的内容类型
public enum LPModifyContentType {
    // 修改用户名（昵称）
    case nickname
    // 修改联系方式
    case contactInfo(type: LPContactInfoType)
}

// MARK: 修改资料页面（如：修改昵称，联系方式）
class LPModifyDataViewController: LPBaseViewController {
    
    // 修改的内容类型
    var modifyContentType: LPModifyContentType = .nickname
    // 占位文本
    var placeholder: String?
    // 文本内容
    var textContent: String?
    // 实际内容长度
    var contentNum = 0
    // 字数限制长度
    var limitedNum = 16
    // 限制Label 的text
    var limitedNumText: String {
        
        return String(format: "%@/%@", String(contentNum),String(limitedNum))
    }
    
    // 修改内容闭包
    public var modifyContentClosure: ((String) -> Void)?
    // 内容输入框
    private let textField = UITextField()
    // 限制Label
    private let wordsCountLabel = UILabel()
    /// 右上角按钮
    var saveButton: UIButton!
    
    convenience init(modifyContentType: LPModifyContentType = .nickname,
                     textContent: String? = nil,
                     limitedNum: Int = 16) {
        self.init()

        self.modifyContentType = modifyContentType
        self.textContent = textContent
        self.contentNum = textContent?.count ?? 0
        self.limitedNum = limitedNum
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNav()
        configureView()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        if lp_isDarkMode { // 右上角按钮，暗黑适配
//            saveButton.contentEdgeInsets = .zero
//            saveButton.layer.cornerRadius = 0
//            saveButton.contentHorizontalAlignment = .right
//
//        } else {
//            saveButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
//            saveButton.layer.cornerRadius = 16
//            saveButton.contentHorizontalAlignment = .center
//        }
//    }
    
    // 设置导航栏
    func setNav() {
        
        lp_NavTitle = getTitleText()
        // 设置导航栏右边按钮
        
        let saveButton = LPSaveButton()
        saveButton.saveButton.addTarget(self, action: #selector(saveNameAction), for: .touchUpInside)
        lp_NavRightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.frame = CGRect(x: 0, y: 0, width: saveButton.saveButton.frame.size.width, height: 32)

        self.saveButton = saveButton.saveButton
        
//        let saveButton = UIButton(type: .custom)
//        saveButton.setTitle("save".localized, for: .normal)
//        saveButton.setTitleColor(.green_64FF00_or_333333, for: .normal)
//        saveButton.titleLabel?.font = .lp_Semibold(16)
//        saveButton.addTarget(self, action: #selector(saveNameAction), for: .touchUpInside)
//        saveButton.backgroundColor = .clear_c_or_64FF00
//        saveButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
//        saveButton.layer.cornerRadius = 16
//        self.saveButton = saveButton
//        lp_NavRightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
    }
    
    // 设置视图
    func configureView() {
        
        let containerView = UIView()
        containerView.backgroundColor = .lp_card
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        
        let titleLabel = UILabel()
        titleLabel.textColor = .gray_999999
        titleLabel.font = .lp_Regular(14)
        containerView.addSubview(titleLabel)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        titleLabel.text = getTitleText(isNav: false)
        
        textField.text = textContent
        textField.backgroundColor = .clear
        textField.textColor = .white_w_or_333333
        textField.font = .lp_Regular(14)
        textField.attributedPlaceholder = NSAttributedString.lp_setAttributedColorText(getPlaceholder(),
                                                                                       getPlaceholder(),
                                                                                       color: .gray_BBBBBB)
        //textField.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "mine_modify_name_tip".localized, attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray_BBBBBB, NSAttributedString.Key.font: UIFont.lp_Regular(14)])
        textField.addTarget(self, action:#selector(textFieldChange(tf:)), for: .editingChanged)
        containerView.isUserInteractionEnabled = true
        containerView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        wordsCountLabel.textColor = .gray_999999
        wordsCountLabel.font = .lp_Medium(14)
        view.addSubview(wordsCountLabel)
        wordsCountLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(15)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        wordsCountLabel.text = limitedNumText
    }
    
    // 获取标题文本
    func getTitleText(isNav: Bool = true) -> String{
        
        switch modifyContentType {
        case .nickname:
            return isNav ? "mine_modify_name".localized : "nickname".localized
        case .contactInfo(type: let type):
            switch type{
            case .email:
                return "mine_email".localized
            default:
                return type.rawValue.capitalized
            }
        }
    }
    
    // 获取占位文本
    func getPlaceholder() -> String {
        
        switch modifyContentType {
        case .nickname:
            return "mine_modify_name_tip".localized
        case .contactInfo(type: let type):
            return ""
        }
    }
}

extension LPModifyDataViewController {
    
    ///最多输入16个字 显示已输入字数
    @objc func textFieldChange(tf:UITextField){
        //markedTextRange!=nil是高亮，正在输入拼音
        if tf.markedTextRange != nil {return}
        guard var inputString = tf.text else {return}

        if inputString.count > limitedNum {
            let startIndex = inputString.startIndex
            let endIndex = inputString.index(startIndex, offsetBy: limitedNum - 1)
            inputString = String(inputString[startIndex...endIndex])
        }
        tf.text = inputString

        // 内容长度
        contentNum = inputString.count
        wordsCountLabel.text = limitedNumText
    }

    ///点击键盘落下
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(false)
    }
    
    ///保存昵称
    @objc func saveNameAction() {
        
        guard let contentText = textField.text else { return }
        switch modifyContentType {
        case .nickname:
            // 不支持内容为 ""
            guard contentText.count > 0 else {
                LPToast.show(message: "mine_modify_name_tip".localized)
                return
            }
            // 请求修改用户名
            modifyUserName(userName: contentText)
        case .contactInfo(type: let type):
            if type == .email {
                
                // 支持内容为 ""
                guard contentText.isEmpty == true || contentText.lp_validateEmail else {
                    LPToast.show(message: "mine_modify_contactEmail_tip".localized)
                    return
                }
            }
            
            //保存用户联系方式
            saveUserContactInfo(type: type, value: contentText)
        }
    }
}

// MARK: 网络请求
extension LPModifyDataViewController {
    
    // 请求修改用户名
    func modifyUserName(userName: String) {
        LPToast.show()
        LPAPIProvider<LPMineAPI>().make(LPMineAPI.modifyUserName(userName: userName)) { [weak self] result in
            LPToast.dismiss()
            if result.isSuccess {
                self?.modifyContentClosure?(userName)
                self?.navigationController?.popViewController(animated: true)
            }else{
                //show
                LPToast.show(message: result.error?.errorMsg)
            }
        }
    }
    
    //保存用户联系方式（contactType： email、facebook、twitter）
    func saveUserContactInfo(type: LPContactInfoType, value: String) {
        
        LPToast.show()
        LPAPIProvider<LPMineAPI>().make(LPMineAPI.saveUserContact(type: type, value: value)) { [weak self] result in
            LPToast.dismiss()
            
            if result.isSuccess {
                self?.modifyContentClosure?(value)
                self?.navigationController?.popViewController(animated: true)
            }else{
                //show
                LPToast.show(message: result.error?.errorMsg)
            }
        }
    }
}
