//
//  ProgressBar.swift
//  xcodeinstall
//
//  Created by Stormacq, Sebastien on 12/09/2022.
//

import Foundation

protocol ProgressUpdateProtocol {
    /// Update the animation with a new step.
    /// - Parameters:
    ///   - step: The index of the operation's current step.
    ///   - total: The total number of steps before the operation is complete.
    ///   - text: The description of the current step.
    func update(step: Int, total: Int, text: String)

    /// Complete the animation.
    /// - Parameters:
    ///   - success: Defines if the operation the animation represents was succesful.
    func complete(success: Bool)

    /// Clear the animation.
    func clear()
}

enum ProgressBarType {
    case percentProgressAnimation
    case countingProgressAnimation
    case countingProgressAnimationMultiLine
}

class ProgressBar: ProgressUpdateProtocol {

    private let progressBarType: ProgressBarType
    private var output: OutputBuffer
    private let title: String?
    private var titlePrinted = false

    private let bold = "\u{001B}[1m"
    private let blue = "\u{001B}[0;34m"
    private let reset = "\u{001B}[0;0m"

    var width: Int = 60
    var fullSign: String = "=" // "🁢"
    var emptySign: String = "-"

    init(output: OutputBuffer, progressBarType: ProgressBarType, title: String? = nil) {
        self.output = output
        // self.output.write("")
        self.progressBarType = progressBarType
        self.title = title
    }

    func update(step: Int, total: Int, text: String = "") {

        if (!titlePrinted),
           let title {

            if self.progressBarType == .percentProgressAnimation {

                // for progress bar - center the title on the bar
                let numberOfSpaces = self.width - title.count
                let prefix = " " * ((numberOfSpaces / 2) + "99% [".count)
                output.write("\(prefix)\(blue)\(bold)\(title)\(reset)\n")
            } else {
                // other wise the title is left-aligned
                output.write("\(blue)\(bold)\(title)\(reset)\n")
            }
            self.titlePrinted = true
        }
        switch self.progressBarType {
        case .percentProgressAnimation:
            percentProgress(step: step, total: total, text: text)

        case .countingProgressAnimation:
            countingProgress(step: step, total: total, text: text)

        case .countingProgressAnimationMultiLine:
            countingProgressMultiLine(step: step, total: total, text: text)
        }
    }

    func clear() {
        // clear current line
        output.clear()

        if titlePrinted {
            // move cursor up and clear that line too
            output.write("\u{001B}[1A")
            output.clear()
        }
    }

    func complete(success: Bool) {
        if success {
            output.write("[ OK ]\n")
        } else {
            output.write("[ Error ]\n")
        }
    }

    private func percentProgress(step: Int, total: Int, text: String = "") {
        let progress = Float(step) / Float(total)
        let numberOfBars = Int(floor(progress * Float(width)))
        let numberOfTicks = width - numberOfBars
        let bars = fullSign * numberOfBars
        let ticks = emptySign * numberOfTicks

        let percentage = Int(floor(progress * 100))
        var string = ""
        string += "\(percentage)% "
        string += "[\(bars)\(ticks)]"
        if text.count > 0 {
            string += " \(text)"
        }
        output.write(string)

        if step >= total {
            // last line
            output.write("\n")
        }
    }

    private func countingProgress(step: Int, total: Int, text: String = "") {
        output.clear()
        output.write("[\(step)/\(total)] \(text)")
        if step >= total {
            // last line
            output.write("\n")
        }
    }

    private func countingProgressMultiLine(step: Int, total: Int, text: String = "") {
        output.write("[\(step)/\(total)] \(text)\n")
    }

}

extension String {
    static func * (char: String, count: Int) -> String {
        var str = ""
        for _ in 0..<count {
            str.append(char)
        }
        return str
    }
}
