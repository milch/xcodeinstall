//
//  InstallCommand.swift
//  xcodeinstall
//
//  Created by Stormacq, Sebastien on 22/08/2022.
//

import Foundation
import CLIlib

extension XCodeInstall {

    func install(file: String?) async throws {
        
        let installer = ShellInstaller()

        // progress bar to report progress feedback
        let progressBar = env.progressBar
        progressBar.define(animationType: .countingProgressAnimationMultiLine,
                           message: "Installing...")
        
        var fileToInstall: URL?
        do {
            // when no file is specified, prompt user to select one
            if  nil == file {
                fileToInstall = try promptForFile()
            } else {
                fileToInstall = FileHandler.downloadDirectory.appendingPathComponent(file!)
            }
            log.debug("Going to attemp to install \(fileToInstall!.path)")

            try await installer.install(file: fileToInstall!)
            env.progressBar.complete(success: true)
            display("✅ \(fileToInstall!) installed")
        } catch CLIError.invalidInput {
            display("🛑 Invalid input")
            env.progressBar.complete(success: false)
        } catch FileHandlerError.noDownloadedList {
            display("⚠️ There is no downloaded file to be installed")
            env.progressBar.complete(success: false)
        } catch InstallerError.xCodeXIPInstallationError {
            display("🛑 Can not expand XIP file. Is there enough space on / ? (16GiB required)")
            env.progressBar.complete(success: false)
        } catch InstallerError.xCodeMoveInstallationError {
            display("🛑 Can not move Xcode to /Applications")
            env.progressBar.complete(success: false)
        } catch InstallerError.xCodePKGInstallationError {
            display("🛑 Can not install additional packages. Be sure to run this command as root (sudo xcodinstall).")
            env.progressBar.complete(success: false)
        } catch InstallerError.unsupportedInstallation {
            display("🛑 Unsupported installation type. (We support Xcode XIP files and Command Line Tools PKG)")
            env.progressBar.complete(success: false)
        } catch {
            display("🛑 Error while installing \(String(describing: fileToInstall!))")
            log.debug("\(error)")
            env.progressBar.complete(success: false)
        }
    }

    func promptForFile() throws -> URL {

        // list files ready to install
        let installableFiles = try env.fileHandler.downloadedFiles().filter({ fileName in
            return fileName.hasSuffix(".xip") || fileName.hasSuffix(".dmg")
        })

        display("")
        display("👉 Here is the list of available files to install:")
        display("")
        let printableList = installableFiles.enumerated().map({ (index, fileName) in
            return "[\(String(format: "%02d", index))] \(fileName)"
        }).joined(separator: "\n")
        display(printableList)
        display("\(installableFiles.count) items")

        let response: String? = env.readLine.readLine(prompt: "⌨️  Which one do you want to install? ", silent: false)
        guard let number = response,
              let num = Int(number) else {

            if (response ?? "") == "" {
                Darwin.exit(0)
            }
            throw CLIError.invalidInput
        }

        return FileHandler.downloadDirectory.appendingPathComponent(installableFiles[num])
    }
}
