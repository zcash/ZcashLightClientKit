//
//  BlockDownloader.swift
//  ZcashLightClientKit
//
//  Created by Francisco Gindre on 17/09/2019.
//  Copyright © 2019 Electric Coin Company. All rights reserved.
//

import Foundation

enum CompactBlockDownloadError: Error {
    case timeout
    case generalError(error: Error)
}

protocol CompactBlockDownloading {
    
    func downloadBlockRange(_ heightRange: CompactBlockRange,
                            completion: @escaping (Error?) -> Void)
    
    func rewind(to height: BlockHeight, completion: @escaping (Error?) -> Void)
    
    func latestBlockHeight(result: @escaping (Result<BlockHeight,Error>) -> Void)
    
}


class CompactBlockDownloader {
    
    fileprivate var lightwalletService: LightWalletService
    fileprivate var storage: CompactBlockAsyncStoring
    
    init(service: LightWalletService, storage: CompactBlockAsyncStoring) {
        self.lightwalletService = service
        self.storage = storage
    }
}

extension CompactBlockDownloader: CompactBlockDownloading {
    
    /**
     Downloads and stores the given block range.
     */
    func downloadBlockRange(_ heightRange: CompactBlockRange,
                            completion: @escaping (Error?) -> Void) {
        
        lightwalletService.blockRange(heightRange) { [weak self] (result) in
            
            guard let self = self else {
                return
            }
            
            switch result{
            case .failure(let error):
                completion(error)
                return
            case .success(let compactBlocks):
                self.storage.write(blocks: compactBlocks) { (storeError) in
                    completion(storeError)
                }
            }
        }
        
    }
    
    
     func rewind(to height: BlockHeight, completion: @escaping (Error?) -> Void){
        
        storage.rewind(to: height) { (e) in
            
            completion(e)
            
        }
    }
    
    func latestBlockHeight(result: @escaping (Result<BlockHeight,Error>) -> Void) {
        
        storage.latestHeight { (r) in
          
            switch r {
            case .failure(let e):
                result(.failure(CompactBlockDownloadError.generalError(error: e)))
                return
            case .success(let height):
                result(.success(height))
            }
            
        }
        
    }
    
}
