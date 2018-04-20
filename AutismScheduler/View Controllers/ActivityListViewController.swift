//
//  ActivityListViewController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/19/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

class ActivityListViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var activityNameTextField: UITextField!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var saveImageButton: UIButton!
    @IBOutlet weak var activityListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var activity: Activity?
    let activityController = ActivityController.shared
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityListTableView.reloadData()
    }
    
    // MARK: - Formatting
    func updateViews() {
        selectImageButton.layer.cornerRadius = 5
        selectImageButton.layer.borderWidth = 0.1
        saveImageButton.layer.cornerRadius = 5
        saveImageButton.layer.borderWidth = 0.1
        activityNameTextField.layer.cornerRadius = 5
        activityNameTextField.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func selectImageButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func saveImageButtonTapped(_ sender: UIButton) {
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
