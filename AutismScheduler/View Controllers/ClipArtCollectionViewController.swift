//
//  ClipArtCollectionViewController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 5/4/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ClipArtCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    let clipartArray = [#imageLiteral(resourceName: "clipartToilet.png"), #imageLiteral(resourceName: "clipartHotdog.png"), #imageLiteral(resourceName: "clipartShirt.png"), #imageLiteral(resourceName: "clipartBroom.png"), #imageLiteral(resourceName: "clipartPizza.png"), #imageLiteral(resourceName: "clipartBook.png"), #imageLiteral(resourceName: "clipartBed")]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutCollectionView()
    }
    
    func layoutCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView?.collectionViewLayout = layout
    }
    
    /*
     
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clipartArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clipartCell", for: indexPath) as? ClipArtCollectionViewCell else { return UICollectionViewCell() }
        cell.clipartImageView.image = clipartArray[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width / 4)
        let height = width
        return CGSize(width: width, height: height)
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
