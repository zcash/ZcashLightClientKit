//
//  DatabaseMigrationManager.swift
//  ZcashLightClientKit
//
//  Created by Francisco Gindre on 3/31/21.
//

import Foundation
import SQLite

class MigrationManager {
    enum DataDbMigrations: Int32 {
        case none = 0
        case version1 = 1
    }
    
    enum CacheDbMigration: Int32 {
        case none = 0
    }
    
    enum PendingDbMigration: Int32 {
        case none = 0
    }
    
    var cacheDb: ConnectionProvider
    var dataDb: ConnectionProvider
    var pendingDb: ConnectionProvider
    
    init(cacheDbConnection: ConnectionProvider,
         dataDbConnection: ConnectionProvider,
         pendingDbConnection: ConnectionProvider) {
        self.cacheDb = cacheDbConnection
        self.dataDb = dataDbConnection
        self.pendingDb = pendingDbConnection
    }
    
    static let latestDataDbMigrationVersion: Int32 = DataDbMigrations.version1.rawValue
    static let latestCacheDbMigrationVersion: Int32 = CacheDbMigration.none.rawValue
    static let latestPendingDbMigrationVersion: Int32 = PendingDbMigration.none.rawValue
    
    func performMigration(seedBytes: [UInt8]) throws {
        let currentPendingDbVersion = try pendingDb.connection().getUserVersion()
        
        try migrateDataDb(seedBytes: seedBytes)
        try migrateCacheDb()
        try migratePendingDb()
    }
    
    fileprivate func migratePendingDb() throws {
        let currentPendingDbVersion = try pendingDb.connection().getUserVersion()
        
        LoggerProxy.debug("Attempting to perform migration for pending Db - currentVersion: \(currentPendingDbVersion). Latest version is: \(Self.latestPendingDbMigrationVersion)")
        
        if currentPendingDbVersion < Self.latestPendingDbMigrationVersion {
            // perform no migration just adjust the version number
            try self.cacheDb.connection().setUserVersion(PendingDbMigration.none.rawValue)
        } else {
            LoggerProxy.debug("PendingDb Db - no migration needed")
        }
    }
    
    fileprivate func migrateCacheDb() throws {
        let currentCacheDbVersion = try cacheDb.connection().getUserVersion()
        
        LoggerProxy.debug("Attempting to perform migration for cache Db - currentVersion: \(currentCacheDbVersion). Latest version is: \(Self.latestCacheDbMigrationVersion)")
        
        if currentCacheDbVersion < Self.latestCacheDbMigrationVersion {
            // perform no migration just adjust the version number
            try self.cacheDb.connection().setUserVersion(CacheDbMigration.none.rawValue)
        } else {
            LoggerProxy.debug("Cache Db - no migration needed")
        }
    }
    
    fileprivate func migrateDataDb(seedBytes: [UInt8]) throws {
        let currentDataDbVersion = try dataDb.connection().getUserVersion()
        LoggerProxy.debug("Attempting to perform migration for data Db - currentVersion: \(currentDataDbVersion). Latest version is: \(Self.latestDataDbMigrationVersion)")
        
        if currentDataDbVersion < Self.latestDataDbMigrationVersion {
            for v in (currentDataDbVersion + 1) ... Self.latestDataDbMigrationVersion {
                guard let version = DataDbMigrations.init(rawValue: v) else {
                    LoggerProxy.error("failed to determine migration version")
                    throw StorageError.invalidMigrationVersion(version: v)
                }
                switch version {
                case .version1:
                    try performVersion1Migration(seedBytes)
                case .none:
                    break
                }
            }
        } else {
            LoggerProxy.debug("Data Db - no migration needed")
        }
    }
    
    func performVersion1Migration(_ seedBytes: [UInt8]) throws {
        LoggerProxy.debug("Starting migration version 1")
        let db = try self.dataDb.connection()
       
        let placeholder = "deriveMe"
        let migrationStatement = """
                    BEGIN TRANSACTION;
                    PRAGMA foreign_keys = OFF;
                    DROP TABLE utxos;
                    CREATE TABLE IF NOT EXISTS utxos(
                                id_utxo INTEGER PRIMARY KEY,
                                address TEXT NOT NULL,
                                prevout_txid BLOB NOT NULL,
                                prevout_idx INTEGER NOT NULL,
                                script BLOB NOT NULL,
                                value_zat INTEGER NOT NULL,
                                height INTEGER NOT NULL,
                                spent_in_tx INTEGER,
                                FOREIGN KEY (spent_in_tx) REFERENCES transactions(id_tx),
                                CONSTRAINT tx_outpoint UNIQUE (prevout_txid, prevout_idx));
                    
                    CREATE TABLE IF NOT EXISTS accounts_new (
                                account INTEGER PRIMARY KEY,
                                extfvk TEXT NOT NULL,
                                address TEXT NOT NULL,
                                transparent_address TEXT NOT NULL
                            );

                    INSERT INTO accounts_new SELECT account, extfvk, address, '\(placeholder)' FROM accounts;
                    DROP TABLE accounts;

                    ALTER TABLE accounts_new RENAME TO accounts;

                    PRAGMA user_version = 1;
                    PRAGMA foreign_keys = ON;
                    COMMIT TRANSACTION;
                    """
        LoggerProxy.debug("db.execute(\"\(migrationStatement)\")")
        try db.execute(migrationStatement)
            
        
        LoggerProxy.debug("db.run() succeeded")
        // derive transparent (shielding) addresses
        
        let accountsDao = AccountSQDAO(dbProvider: self.dataDb)
        
        let accounts = try accountsDao.getAll()
        
        guard !accounts.isEmpty else {
            LoggerProxy.debug("no existing accounts found while performing this migration")
            return
        }
        let derivationTool = DerivationTool.default
        for var a in accounts {
            let tAddr = try derivationTool.deriveTransparentAddress(seed: seedBytes, account: a.account, index: 0)
            a.transparentAddress = tAddr
            try accountsDao.update(a)
        }
        
//         sanity check
        guard try accountsDao.getAll().first(where: { $0.transparentAddress == placeholder}) == nil else {
            LoggerProxy.error("Accounts Migration performed but the transparent addresses were not derived")
            throw StorageError.migrationFailed(underlyingError: KeyDerivationErrors.unableToDerive)
        }
    }
}

extension Connection {
    func getUserVersion() throws -> Int32 {
        guard let v = try scalar("PRAGMA user_version") as? Int64 else {
            return 0
        }
        return Int32(v)
    }
    
    func setUserVersion(_ version: Int32) throws {
        try run("PRAGMA user_version = \(version)")
    }
}