//
//  MainViewController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewAndAssignButton: UIButton!
    @IBOutlet weak var createActivityButton: UIButton!
    @IBOutlet weak var createTaskButton: UIButton!
    let childController = ChildController.shared
    var children = ChildController.shared.children
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatCollectionView()
        childController.loadCloudBackup()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    func formatCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if children.count == 0 {
            let height = (view.frame.height * (1/3))
            let width = (view.frame.width * (9/10))
            return CGSize(width: width, height: height)
        } else {
            let height = (view.frame.height * (1/3))
            let width = height
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if children.count == 0 {
            return 1
        } else {
            return children.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if children.count == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noChildCell", for: indexPath) as? NoChildCollectionViewCell else { return UICollectionViewCell() }
            collectionView.allowsSelection = false
            collectionView.isScrollEnabled = false
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "childCell", for: indexPath) as? ChildCollectionViewCell else { return UICollectionViewCell() }
            let child = children[indexPath.row]
            cell.childImageView.image = child.image
            cell.childNameLabel.text = child.name
            if collectionView.allowsSelection != true {
                collectionView.allowsSelection = true
            }
            if collectionView.isScrollEnabled != true {
                collectionView.isScrollEnabled = true
            }
            return cell
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
