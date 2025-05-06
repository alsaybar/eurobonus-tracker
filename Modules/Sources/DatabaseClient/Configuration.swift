//
//  Configuration.swift
//  Modules
//
//  Created by Christian Alsaybar on 16/03/2025.
//

import GRDB
import OSLog

private let sqlLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SQL")

public func makeConfiguration(_ config: Configuration = Configuration()) -> Configuration {
    var config = config
    config.foreignKeysEnabled = true

    #if DEBUG
        config.prepareDatabase { db in
            db.trace { event in
                sqlLogger.debug("GRDB: \(event.expandedDescription)")
            }
        }
        config.publicStatementArguments = true
    #endif

    return config
}
