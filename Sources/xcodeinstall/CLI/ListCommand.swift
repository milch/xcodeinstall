//
//  ListCommand.swift
//  xcodeinstall
//
//  Created by Stormacq, Sebastien on 16/08/2022.
//

import Foundation

extension XCodeInstall {

    func list(force: Bool,
              xCodeOnly: Bool,
              majorVersion: String,
              sortMostRecentFirst: Bool,
              datePublished: Bool) async throws -> [DownloadList.Download] {

        guard let download = downloader else {
            throw XCodeInstallError.configurationError(msg: "Developer forgot to inject a downloader object. " +
                                                             "Use XCodeInstallBuilder to correctly initialize this class") // swiftlint:disable:this line_length
        }

        let filehandler = FileHandler(logger: logger)

        display("Loading list of available downloads ", terminator: "")
        display("\(force ? "forced download from Apple Developer Portal" : "fetched from cache in \(filehandler.baseFilePath())")") // swiftlint:disable:this line_length

        do {
            let list = try await download.list(force: force)
            display("✅ Done")

            let parser = DownloadListParser(logger: logger,
                                            xCodeOnly: xCodeOnly,
                                            majorVersion: majorVersion,
                                            sortMostRecentFirst: sortMostRecentFirst)
            let parsedList = try parser.parse(list: list)

            // enrich the list to flag files already downloaded
            let enrichedList = parser.enrich(list: parsedList)

            display("")
            display("👉 Here is the list of available downloads:")
            display("Files marked with (*) are already downloaded in \(filehandler.baseFilePath()) ")
            display("")
            let string = parser.prettyPrint(list: enrichedList, withDate: datePublished)
            display(string)
            display("\(enrichedList.count) items")

            return enrichedList

        } catch DownloadError.authenticationRequired {
            display("🛑 Session expired, you neeed to re-authenticate.")
            display("You can authenticate with the command: xcodeinstall authenticate")

            // todo launch authentifictaion automatically ?
            throw DownloadError.authenticationRequired

        } catch {
            display("🛑 Unexpected error : \(error)")
            throw error
        }

    }
}
