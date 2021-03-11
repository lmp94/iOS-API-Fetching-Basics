//
//  ViewController.swift
//  API Fetching Non Swift UI
//
//  Created by Larissa Perara on 3/11/21.
//

import UIKit

class ViewController: UIViewController {
    
    let iacoDataModel: IACODataModel = IACODataModel.shared
    var label: UILabel = UILabel()
    var button: UIButton = UIButton()
    
    // Really you should have a separate view class that is referenced in here
    // that does the mangement of the view specifics while the VC should be
    // managing the views and getting data to and from the views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label = createLabel()
        button = createButton()
        
        self.view.addSubview(button)
        self.view.addSubview(label)
    }
    
    func createLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.text = "Hello World"
        return label
    }
    
    func createButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .green
        button.setTitle("IACO", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return button
    }
    
    @objc func buttonPressed(sender: UIButton) {
        print("button pressed!")
       
        iacoDataModel.requestIACOData("KMHR,KMCC,KAUN,KPVF") { [weak self] data in
            guard let strongSelf = self else {
                print("no access to self")
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    strongSelf.label.text = "API Call Failed"
                }
                print("Data request failed")
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.label.text = data
            }
            print(data)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
