//
//  BlockGroundAPIManager.swift
//  AC3.2-LocalStorage
//
//  Created by Louis Tur on 1/16/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import UIKit


struct BlockGroundConstant {
    static let notSet = "Not Set"
    static let baseURL = "https://api.fieldbook.com/v1/"
    static let imageEndPoint = "/images"
}

// add in download delegation
internal class BlockGroundAPIManager: NSObject, URLSessionDownloadDelegate {
    private var bookId: String
    private var baseURL: String
    private var session: URLSession!
    internal var downloadDelegate: BlockGroundAPIDelegate?
    
    static let shared: BlockGroundAPIManager = BlockGroundAPIManager()
    private override init() {
        bookId = BlockGroundConstant.notSet
        baseURL = BlockGroundConstant.baseURL
    }
    
    internal func configure(bookId: String, baseURL: String = BlockGroundConstant.baseURL) {
        self.bookId = bookId
        self.baseURL = baseURL
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    internal func requestAllBlockGrounds(completion: @escaping ([BlockGround]?, Error?)->Void) {
        
        // define URL from base + bookId + endpoint
        let url = URL(string: BlockGroundConstant.baseURL + bookId + BlockGroundConstant.imageEndPoint)!
        
        // create data task
        session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            
            // check for errors
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
            }
            
            // check for data
            guard let validData = data else { return }
            
            do {
                let json: Any = try JSONSerialization.jsonObject(with: validData, options: [])
                guard let dictArr: [[String: AnyHashable]] = json as? [[String: AnyHashable]] else { return }
                
                // parse model objects
                let blockGroundArr: [BlockGround] = dictArr.map { BlockGround(json: $0)! }
//                for dict in dictArr {
//                    if let thisBG = try BlockGround(json: dict) {
//                        blockGroundArr.append(thisBG)
//                    }
//                }
                
                // implement completions
                completion(blockGroundArr, error)
            
            } catch let error as NSError {
                print("Error occurred while parsing data: \(error.localizedDescription)")
            }
            
            }.resume()
    }
    
    internal func downloadBlockGround(_ blockground: BlockGround) {
        // define url from blockground model
        let url = URL(string: blockground.imageFullResURL)!
        // create download task for session.. with or without handler?
        let downloadTask = session.downloadTask(with: url)
        // give task a description
        downloadTask.taskDescription = blockground.shortName
        // start task
        downloadTask.resume()
        
//        { (url: URL?, response: URLResponse?, error: Error?) in
//            if error != nil {
//                print(error!.localizedDescription)
//            }
//            if let url = url {
//                do {
//                    let imageData = try Data(contentsOf: url)
//                    if let imageFromData = UIImage(data: imageData) {
//                        completion(imageFromData)
//                    }
//                }
//                catch {
//                }
//            }
//        }.resume()
        
    }
    
    // MARK: - Download Delegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // check for finished download
        self.downloadDelegate?.didDownlowd(downloadTask, to: location)
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // keep track of periodic downloads
        
        // check for % completed and print
        let progressPercent = (Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)) * 100
                
        self.downloadDelegate?.downloadInProgress(task: downloadTask, progress: Double(progressPercent))
        
        // what do we do when the nsurl session transfer size is unknown?
        // lets display some info at least (MB)
    }
    
}
