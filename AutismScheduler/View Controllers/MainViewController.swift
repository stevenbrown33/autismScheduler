//
//  MainViewController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AddChildDelegate, ChildControllerDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addChildButton: UIButton!
    
    var children:[Child] = []
    let childController = ChildController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notification()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.isNavigationBarHidden = true
        formatCollectionView()
        collectionView.reloadData()
        formatting()
        childrenUpdated()
        NotificationCenter.default.addObserver(self, selector: #selector(updateCollectionView), name: .updateCollectionView, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func formatting() {
        view.backgroundColor = .defaultBackgroundColor
//        let backgroundLayer = UIHelper.shared.gradientLayer
//        backgroundLayer.frame = view.frame
//        view.layer.insertSublayer(backgroundLayer, at: 0)
        
        addChildButton.layer.cornerRadius = UIHelper.shared.defaultButtonCornerRadius
        addChildButton.backgroundColor = .defaultButtonColor
        addChildButton.tintColor = .defaultButtonTextColor
        
        navigationController?.navigationBar.tintColor = .defaultTintColor
    }
    
    func childrenUpdated() {
        children = childController.children
        collectionView.reloadData()
    }
    
    func notification() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshViews), name: childrenWereSetNotification, object: nil)
    }
    
    @objc func updateCollectionView() {
        collectionView.reloadData()
    }
    
    @objc func refreshViews() {
        collectionView.reloadData()
    }
    
    @IBAction func addChildButtonTapped(_ sender: UIButton) {
    }
    
    func formatCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.height * 0.4
        let width = view.frame.width * 0.8
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if childController.children.count == 0 {
            return 1
        } else {
            return childController.children.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentChild = childController.children[indexPath.row]
        childController.currentChild = currentChild
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if childController.children.count == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noChildCell", for: indexPath) as? NoChildCollectionViewCell else { return UICollectionViewCell() }
            if collectionView.allowsSelection == true {
                collectionView.allowsSelection = false
            }
            if collectionView.isScrollEnabled == true {
                collectionView.isScrollEnabled = false
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "childCell", for: indexPath) as? ChildCollectionViewCell else { return UICollectionViewCell() }
            let child = childController.children[indexPath.row]
            cell.child = child
            if collectionView.allowsSelection != true {
                collectionView.allowsSelection = true
            }
            if collectionView.isScrollEnabled != true {
                collectionView.isScrollEnabled = true
            }
            return cell
        }
    }
    
     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChildDetail",
            let indexPath = collectionView.indexPath(for: sender as! UICollectionViewCell) {
            let detailVC = segue.destination as? UINavigationController
            let addChildVC = detailVC?.viewControllers.first as? AddChildViewController
            let child = childController.children[indexPath.row]
            addChildVC?.child = child
            addChildVC?.delegate = self
        } else if segue.identifier == "toAddChild" {
            let detailVC = segue.destination as? UINavigationController
            let addChildVC = detailVC?.viewControllers.first as? AddChildViewController
            addChildVC?.delegate = self
        }
     }
    
    func viewActivities() {
        tabBarController?.selectedIndex = 1
    }
}

extension Notification.Name {
    static let updateCollectionView = Notification.Name("updateCollectionView")
}
