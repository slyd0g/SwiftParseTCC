//
//  main.swift
//  SwiftParseTCC
//
//  Created by Justin Bui on 7/26/21.
//

import Foundation
import SQLite3

func toBase64(data: Data) -> String {
    return data.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
}

func querySchema(db: OpaquePointer) {
    let queryStatementString = "PRAGMA table_info(\"access\")"
    var queryStatement: OpaquePointer?
    if sqlite3_prepare_v2(
        db,
        queryStatementString,
        -1,
        &queryStatement,
        nil
    ) == SQLITE_OK {
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
                return
            }
            let name = String(cString: queryResultCol1)
            print(name, "| ", terminator: "")
        }
    } else {
        let errorMessage = String(cString: sqlite3_errmsg(db))
        print("\nQuery is not prepared \(errorMessage)")
    }
    sqlite3_finalize(queryStatement)
}

func queryAccess(db: OpaquePointer) {
    let queryStatementString = "select * from access"
    var queryStatement: OpaquePointer?
    if sqlite3_prepare_v2(
        db,
        queryStatementString,
        -1,
        &queryStatement,
        nil
    ) == SQLITE_OK {
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            var csreq: String
            var policy_id: String
            var indirect_object_identifier_type: String
            var indirect_object_code_identity: String
            var flags: String
            
            guard let queryService = sqlite3_column_text(queryStatement, 0) else {
                return
            }
            guard let queryClient = sqlite3_column_text(queryStatement, 1) else {
                return
            }
            guard let queryClientType = sqlite3_column_text(queryStatement, 2) else {
                return
            }
            guard let queryAuthValue = sqlite3_column_text(queryStatement, 3) else {
                return
            }
            guard let queryAuthReason = sqlite3_column_text(queryStatement, 4) else {
                return
            }
            guard let queryAuthVersion = sqlite3_column_text(queryStatement, 5) else {
                return
            }
            if let queryCsreq = sqlite3_column_blob(queryStatement, 6) {
                let queryCsreqLength = sqlite3_column_bytes(queryStatement, 6)
                let data = Data(bytes: queryCsreq, count: Int(queryCsreqLength))
                csreq = toBase64(data: data)
            }
            else {
                csreq = "<NULL>"
            }
            if let queryPolicyID = sqlite3_column_text(queryStatement, 7) {
                policy_id = String(cString: queryPolicyID)
            }
            else {
                policy_id = "<NULL>"
            }
            if let queryIndirectObjectIdentifierType = sqlite3_column_text(queryStatement, 8) {
                indirect_object_identifier_type = String(cString: queryIndirectObjectIdentifierType)
            }
            else {
                indirect_object_identifier_type = "<NULL>"
            }
            guard let queryIndirectObjectIdentifier = sqlite3_column_text(queryStatement, 9) else {
                return
            }
            if let queryIndirectObjectCodeIdentity = sqlite3_column_blob(queryStatement, 10) {
                let queryIndirectObjectCodeIdentityLength = sqlite3_column_bytes(queryStatement, 10)
                let data = Data(bytes: queryIndirectObjectCodeIdentity, count: Int(queryIndirectObjectCodeIdentityLength))
                indirect_object_code_identity = toBase64(data: data)
            }
            else {
                indirect_object_code_identity = "<NULL>"
            }
            if let queryFlags = sqlite3_column_text(queryStatement, 11) {
                flags = String(cString: queryFlags)
            }
            else {
                flags = "<NULL>"
            }
            guard let queryLastModified = sqlite3_column_text(queryStatement, 12) else {
                return
            }
            
            let service = String(cString: queryService)
            let client = String(cString: queryClient)
            let client_type = String(cString: queryClientType)
            let auth_value = String(cString: queryAuthValue)
            let auth_reason = String(cString: queryAuthReason)
            let auth_version = String(cString: queryAuthVersion)
            let indirect_object_identifier = String(cString: queryIndirectObjectIdentifier)
            let last_modified = String(cString: queryLastModified)
            
            print(service, "|", client, "|", client_type, "|", auth_value, "|", auth_reason, "|", auth_version, "|", csreq, "|", policy_id, "|", indirect_object_identifier_type, "|", indirect_object_identifier, "|", indirect_object_code_identity, "|", flags, "|", last_modified)
        }
    } else {
        let errorMessage = String(cString: sqlite3_errmsg(db))
        print("\nQuery is not prepared \(errorMessage)")
    }
    sqlite3_finalize(queryStatement)
}

func Help()
{
    print("SwiftParseTCC by @slyd0g")
    print("Usage:")
    print("-h || -help                 | Print help menu")
    print("-p || -path /path/to/tcc.db | Path to TCC.db file ")
}


if CommandLine.arguments.count == 1 {
    Help()
    exit(0)
}
else {
    for argument in CommandLine.arguments {
        if (argument.contains("-h") || argument.contains("-help")) {
            Help()
            exit(0)
        }
        else if (argument.contains("-p") || argument.contains("-path")) {
            var path = CommandLine.arguments[2]
            if path.contains("~") {
                path = NSString(string: path).expandingTildeInPath
            }
            let fileURL = URL(fileURLWithPath: path)
            var db: OpaquePointer?
            guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
                print("Error: Could not open \(fileURL.path)")
                sqlite3_close(db)
                db = nil
                exit(0)
            }
            
            querySchema(db: db!)
            print("")
            queryAccess(db: db!)
        }
    }
}
