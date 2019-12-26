//
//  GetAddressViewController.swift
//  ZcashLightClientSample
//
//  Created by Francisco Gindre on 11/1/19.
//  Copyright © 2019 Electric Coin Company. All rights reserved.
//

import UIKit
import ZcashLightClientKit
class GetAddressViewController: UIViewController {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var spendingKeyLabel: UILabel! // THIS SHOULD BE SUPER SECRET!!!!!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addressLabel.text =  legibleAddresses() ?? "No Addresses found"
        spendingKeyLabel.text = SampleStorage.shared.privateKey ?? "No Spending Key found"
        addressLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addressTapped(_:))))
        addressLabel.isUserInteractionEnabled = true
        
        spendingKeyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(spendingKeyTapped(_:))))
        spendingKeyLabel.isUserInteractionEnabled = true
        print("Address: \(String(describing: Initializer.shared.getAddress()))")
        print("Spending Key: \(SampleStorage.shared.privateKey ?? "No Spending Key found")")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func legibleAddresses() -> String? {
        Initializer.shared.getAddress()
    }
    
    @IBAction func spendingKeyTapped(_ gesture: UIGestureRecognizer) {
        print("copied to clipboard")
        UIPasteboard.general.string = legibleAddresses()
        let alert = UIAlertController(title: "", message: "Spending Key Copied to clipboard", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addressTapped(_ gesture: UIGestureRecognizer) {
        print("copied to clipboard")
        UIPasteboard.general.string = legibleAddresses()
        let alert = UIAlertController(title: "", message: "Address Copied to clipboard", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
