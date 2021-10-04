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
    var refreshButton: UIButton = UIButton()
        
    // Really you should have a separate view class that is referenced in here
    // that does the mangement of the view specifics while the VC should be
    // managing the views and getting data to and from the views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label = createLabel()
        button = createButton()
        
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let labelXTop = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let labelYTop = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate([labelXTop, labelYTop])
        label.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true

        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        button.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        button.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: -10).isActive = true
    }
    
    func createLabel() -> UILabel {
        let label = UILabel()
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.text = "Hello World"
        label.numberOfLines = 40
        return label
    }
    
    // Don: You should try to use constraints
    
    func createButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = .gray
        button.setTitle("IACO", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.titleLabel?.textAlignment = .center
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
                //strongSelf.refreshButton.setTitle("Refresh API", for: .normal)
            }
            print(data)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
