//
//  ViewController.swift
//  CalorieApp
//
//  Created by Nikhil Dhavale on 24/05/25.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the SwiftUI view
        let contentView = ContentView()
        
        // Create the hosting controller
        let hostingController = UIHostingController(rootView: contentView)
        
        // Add the hosting controller as a child view controller
        addChild(hostingController)
        
        // Add the hosting controller's view to the view hierarchy
        view.addSubview(hostingController.view)
        
        // Configure the hosting controller's view constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Notify the hosting controller that it was moved to this view controller
        hostingController.didMove(toParent: self)
    }


}

