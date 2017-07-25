//
//  Protocols.swift
//  AC3.2-LocalStorage
//
//  Created by Tom Seymour on 1/19/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation

protocol BlockGroundAPIDelegate {
    func didDownlowd(_ task: URLSessionDownloadTask, to url: URL)
    func downloadInProgress(task: URLSessionDownloadTask, progress: Double)
}
