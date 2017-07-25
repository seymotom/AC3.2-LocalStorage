//
//  BlockGroundFileManager.swift
//  AC3.2-LocalStorage
//
//  Created by Louis Tur on 1/16/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import UIKit

internal class BlockGroundFileManager {
    // private!
    
    // needs: instance of FilemManager... maybe a default?
    //        folder name
    //        rootURL
    //        imagesURL
    
    private let manager: FileManager = FileManager.default
    private let rootFolderName: String = "Blockgrounds"
    private var rootURL: URL!
    private var imagesURL: URL!
    
    
    // singleton
    internal static let shared: BlockGroundFileManager = BlockGroundFileManager()
    private init() {
        // define a rootURL using url(for:in:appropriateFor:create:true)
        do {
            self.rootURL = try manager.url(for: .picturesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            // check that we can actually found it, but how?
            // set break point, po self.url and look up the location in the finder
            
            // create & define a Blockground Images URL relative to the root
            imagesURL = URL(fileURLWithPath: rootFolderName, relativeTo: rootURL)
           try manager.createDirectory(at: imagesURL, withIntermediateDirectories: true, attributes: nil)
            
        } catch {
            print("Error encountered locating root url")
        }
        
        // ok, now try to create the new folder dir with createDirectory(at:withIntermediateDirectories:attributes:)
    }
    
    internal func rootDir() -> URL {
        return self.rootURL
    }
    
    internal func blockgroundsDir() -> URL {
        return self.imagesURL
    }
    
    // list contents of the blockgrounds dir
    internal func listContentsOfBlockgroundsDir() -> [URL]? {
        // get the contents using cotentsOfDirectory(at:includingPropertiesForKeys:, options:)
        do {
            return try manager.contentsOfDirectory(at: blockgroundsDir(), includingPropertiesForKeys: nil, options: [])
        } catch {
            print("Error listing contents of directory: \(error)")
        }
        return nil
    }
    
    internal func save(image: UIImage, to dir: URL = BlockGroundFileManager.shared.blockgroundsDir()) {
        
        // get this to the point where we have an image
    }
    
}
