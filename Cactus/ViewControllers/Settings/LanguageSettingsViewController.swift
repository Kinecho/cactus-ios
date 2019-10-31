//
//  LanguageSettingsViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

struct LanguageChoice {
    var value: String
    var title: String
    var enabled: Bool
    init(title: String, value: String, enabled: Bool = true) {
        self.title = title
        self.value = value
        self.enabled = enabled
    }
}

class LanguageSettingsViewController: UIViewController {
    @IBOutlet weak var languagePickerView: UIPickerView!
    let languages: [LanguageChoice] = [
            LanguageChoice(title: "Engligh", value: "en"),
            LanguageChoice(title: "Spanish", value: "es", enabled: false),
       ]
    var chosenLanguage: LanguageChoice?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        languagePickerView.dataSource = self
        languagePickerView.delegate = self
        
        let prefLangCode = CactusMemberService.sharedInstance.currentMember?.languageCode
        let currentIndex = self.languages.firstIndex(where: { (lang) -> Bool in
            lang.value == prefLangCode
        })
        
        languagePickerView.selectRow(currentIndex ?? 0, inComponent: 0, animated: false)
//        languagePickerView.
        // Do any additional setup after loading the view.
    }

}

extension LanguageSettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.chosenLanguage = self.languages[row]
    }
}
