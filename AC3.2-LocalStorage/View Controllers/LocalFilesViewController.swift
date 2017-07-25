//
//  LocalFilesViewController.swift
//  AC3.2-LocalStorage
//
//  Created by Louis Tur on 1/16/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import SnapKit

class LocalFilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BlockGroundAPIDelegate {
    
    private let cellIdentifier: String = "LocalFileCellIdentifier"
    private var directoryItems: [URL]?
    
    var downloadProgressBar = UIProgressView()
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        configureConstraints()
        
        BlockGroundAPIManager.shared.downloadDelegate = self
        
        // load directory items
        self.directoryItems = BlockGroundFileManager.shared.listContentsOfBlockgroundsDir()
        
        // configure api manager
        BlockGroundAPIManager.shared.configure(bookId: "587d55d093e81a0400aef3b2")
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // request blockgrounds
        BlockGroundAPIManager.shared.requestAllBlockGrounds { (blockground: [BlockGround]?, error: Error?) in
            // check for blockgrounds
            guard let blockGrounds = blockground else { return }
            // download blockground images
            
            // download blockground images
            print("Success")
            print(blockGrounds)
            
            BlockGroundAPIManager.shared.downloadBlockGround(blockGrounds.last!)
        }
    }
    
    
    // MARK: - Setup
    private func configureConstraints() {
        self.edgesForExtendedLayout = []
        
        // lay out views
        
        previewView.snp.makeConstraints { (pv) in
            pv.leading.trailing.top.equalToSuperview()
            pv.height.equalToSuperview().multipliedBy(0.25)
//            pv.top.equalTo(downloadProgressBar.snp.bottom)
        }
        
        downloadProgressBar.snp.makeConstraints { (dp) in
            dp.leading.trailing.equalToSuperview()
            dp.top.equalToSuperview()
            dp.height.equalTo(10)
        }
        
        localFilesTable.snp.makeConstraints { (lft) in
            lft.top.equalTo(previewView.snp.bottom)
            lft.bottom.leading.trailing.equalToSuperview()
        }
        
    }
    
    private func setupViewHierarchy() {
        // add views
        self.view.addSubview(previewView)
        self.view.addSubview(localFilesTable)
        self.view.addSubview(downloadProgressBar)
        // set delegate/datasource
        self.localFilesTable.delegate = self
        self.localFilesTable.dataSource = self
        // register tableview
        self.localFilesTable.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    
    // MARK: - BlockGroundAPIDelegate
    
    func didDownlowd(_ task: URLSessionDownloadTask, to url: URL) {
        do {
            let imageData = try Data(contentsOf: url)
            if let imageFromData = UIImage(data: imageData) {
                BlockGroundFileManager.shared.save(image: imageFromData)
            }
            
        } catch {
            print("")
        }
        
        
        DispatchQueue.main.async {
            self.downloadProgressBar.tintColor = .green
            UIView.animate(withDuration: 0.5, animations: {
                self.downloadProgressBar.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.downloadProgressBar.alpha = 0.0
            }, completion: { (complete) in
                if complete {
                    print("finished animating")
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.75, animations: {
                            self.downloadProgressBar.alpha = 1.0
                            self.downloadProgressBar.transform = CGAffineTransform.identity
                        }, completion: {(x) in
                            if complete {
                                UIView.animate(withDuration: 0.5, animations: { 
                                    self.downloadProgressBar.alpha = 0.0
                                })
                            }
                        })
                    }
                }
            })
            
    
        }
        print(task.taskDescription!)
    }
    
    func downloadInProgress(task: URLSessionDownloadTask, progress: Double) {
        print("Task name: \(task.taskDescription!).... Progress: \(String(format: "%0.1f", progress))%")
        DispatchQueue.main.async {
            self.downloadProgressBar.progress = Float(progress / 100)
            
        }
        print("Progress bar value: ", downloadProgressBar.progress)
    }
    
    
    // MARK: - TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.directoryItems?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = self.directoryItems?[indexPath.row].absoluteURL.lastPathComponent
        print("cell.textLabel.text = \(cell.textLabel?.text)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    // MARK: - Lazy Inits
    internal lazy var previewView: UIImageView = {
        let view: UIImageView = UIImageView()
        view.backgroundColor = .gray
        return view
    }()
    
    internal lazy var localFilesTable: UITableView = {
        let tableView: UITableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
        return tableView
    }()
}
