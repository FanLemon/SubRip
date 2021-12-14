import Foundation



///
/// `SubRip` (SubRip Text) files are named with the extension .srt,
/// and contain formatted lines of plain text in groups separated by a blank line.
/// Subtitles are numbered sequentially, starting at 1.
/// The timecode format used is hours:minutes:seconds,milliseconds with time units fixed to two zero-padded digits
/// and fractions fixed to three zero-padded digits (00:00:00,000).
/// The fractional separator used is the comma, since the program was written in France.
///
/// A numeric counter identifying each sequential subtitle
/// The time that the subtitle should appear on the screen, followed by --> and the time it should disappear
/// Subtitle text itself on one or more lines
/// A blank line containing no text, indicating the end of this subtitle
/// `Example`:
///
/// 1
/// 00:02:16,612 --> 00:02:19,376
/// Senator, we're making
/// our final approach into Coruscant.
///
/// 2
/// 00:02:19,482 --> 00:02:21,609
/// Very good, Lieutenant.
///
/// 3
/// 00:03:13,336 --> 00:03:15,167
/// We made it.
///
/// 4
/// 00:03:18,608 --> 00:03:20,371
/// I guess I was wrong.
///
/// 5
/// 00:03:20,476 --> 00:03:22,671
/// There was no danger at all.
///

protocol TimeIntegerLiteral {
    
    static var numeralBase: Int { get }
    
    static var literalWidth: Int { get }
    
    var integerValue: Int { get set }
    
    init(intValue: Int)
    
    var description: String { get }
    
    static func time(value: Int) -> Self
    
    static func time(str: String) -> Self
}


extension TimeIntegerLiteral {
    
    static func time(value: Int) -> Self {
        return Self.init(intValue: min(max(value, 0), Self.numeralBase-1))
    }
    
    static func time(str: String) -> Self {
        guard let value = Int(str) else {
            return Self.init(intValue: 0)
        }
        
        return Self.time(value: value)
    }
    
    var description: String {
        return String(format: "%0\(Self.literalWidth)d", integerValue)
    }
    
    static func +(lhs: Self, rhs: Int) -> Int {
        return lhs.integerValue + rhs
    }
    
    static func -(lhs: Self, rhs: Int) -> Int {
        return lhs.integerValue - rhs
    }
    
    static func *(lhs: Self, rhs: Int) -> Int {
        return lhs.integerValue * rhs
    }
    
    static func /(lhs: Self, rhs: Int) -> Int {
        guard rhs != 0 else {
            return 0
        }
        return lhs.integerValue / rhs
    }
}


struct TimeNumeraBase24: TimeIntegerLiteral {
    
    static var numeralBase: Int = 24
    
    static var literalWidth: Int = 2
    
    var integerValue: Int = 0
    
    init(intValue: Int) {
        integerValue = intValue
    }
}


struct TimeNumeraBase60: TimeIntegerLiteral {
    
    static var numeralBase: Int = 60
    
    static var literalWidth: Int = 2
    
    var integerValue: Int = 0
    
    init(intValue: Int) {
        integerValue = intValue
    }
}


struct TimeNumeraBase1000: TimeIntegerLiteral {
    
    static var numeralBase: Int = 1000
    
    static var literalWidth: Int = 3
    
    var integerValue: Int = 0
    
    init(intValue: Int) {
        integerValue = intValue
    }
}


///
/// `Zero-padded Timecode`:
///
/// hours:minutes:seconds,milliseconds
/// 00:03:18,608
///
struct Timecode: Equatable {
    
    var hours: TimeNumeraBase24
    var minutes: TimeNumeraBase60
    var seconds: TimeNumeraBase60
    var milliseconds: TimeNumeraBase1000
    
    init() {
        hours = TimeNumeraBase24(intValue: 0)
        minutes = TimeNumeraBase60(intValue: 0)
        seconds = TimeNumeraBase60(intValue: 0)
        milliseconds = TimeNumeraBase1000(intValue: 0)
    }
    
    static func split(_ description: String) -> [String]? {
        /// 0  1  2
        /// -- -- ------
        /// 00:03:18,608
        let hmsComponents = description.components(separatedBy: ":")
        guard hmsComponents.count == 3 else {
            return nil
        }
        
        guard hmsComponents[0].count == 2 else {
            return nil
        }
        
        guard hmsComponents[1].count == 2 else {
            return nil
        }
        
        guard hmsComponents[2].count == 6 else {
            return nil
        }
        
        let sm = hmsComponents[2].components(separatedBy: ",")
        guard sm.count == 2 else {
            return nil
        }
        
        guard sm[0].count == 2 else {
            return nil
        }
        
        guard sm[1].count == 3 else {
            return nil
        }
        
        return [hmsComponents[0], hmsComponents[1], sm[0], sm[1]]
    }
    
    init?(_ description: String) {
        guard let hmsm = Timecode.split(description) else {
            return nil
        }
        
        hours = TimeNumeraBase24.time(str: hmsm[0])
        minutes = TimeNumeraBase60.time(str: hmsm[1])
        seconds = TimeNumeraBase60.time(str: hmsm[2])
        milliseconds = TimeNumeraBase1000.time(str: hmsm[3])
    }
    
    var description: String {
        return hours.description + ":" + minutes.description + ":" + seconds.description + "," + milliseconds.description
    }

    static let MILLISECONDS_PER_SECOND = 1000
    static let MILLISECONDS_PER_MINUTE = 60 * Timecode.MILLISECONDS_PER_SECOND
    static let MILLISECONDS_PER_HOUR = 60 * Timecode.MILLISECONDS_PER_MINUTE
    
    init(milliseconds ms: Int) {
        var millis = max(ms, 0)
        
        let hour = millis / Timecode.MILLISECONDS_PER_HOUR
        millis -= (hour * Timecode.MILLISECONDS_PER_HOUR)
        
        let minute = millis / Timecode.MILLISECONDS_PER_MINUTE
        millis -= minute * Timecode.MILLISECONDS_PER_MINUTE
        
        let second = millis / Timecode.MILLISECONDS_PER_SECOND
        millis -=  second * Timecode.MILLISECONDS_PER_SECOND
        
        let millisecond = millis
        
        hours = TimeNumeraBase24(intValue: hour)
        minutes = TimeNumeraBase60(intValue: minute)
        seconds = TimeNumeraBase60(intValue: second)
        milliseconds = TimeNumeraBase1000(intValue: millisecond)
    }
    
    var millisecondsValue: Int {
        let mmm = milliseconds.integerValue
        let sss = seconds * Timecode.MILLISECONDS_PER_SECOND
        let min = minutes * Timecode.MILLISECONDS_PER_MINUTE
        let hhh = hours * Timecode.MILLISECONDS_PER_HOUR
        
        return hhh + min + sss + mmm
    }
    
    static func +(lhs: Timecode, rhs: Int) -> Timecode {
        return Timecode(milliseconds: lhs.millisecondsValue + rhs)
    }
    
    static func -(lhs: Timecode, rhs: Int) -> Timecode {
        return Timecode(milliseconds: lhs.millisecondsValue - rhs)
    }
    
    static func +(lhs: Timecode, rhs: Timecode) -> Timecode {
        return Timecode(milliseconds: lhs.millisecondsValue + rhs.millisecondsValue)
    }
    
    static func -(lhs: Timecode, rhs: Timecode) -> Timecode {
        return Timecode(milliseconds: lhs.millisecondsValue - rhs.millisecondsValue)
    }
    
    static func == (lhs: Timecode, rhs: Timecode) -> Bool {
        return lhs.millisecondsValue == rhs.millisecondsValue
    }
    
}


///
/// 00:02:19,482 --> 00:02:21,609
///
struct TimeDuration: Equatable {
    
    static let delimiterBlock = " --> "
    
    var start: Timecode
    var end: Timecode
    
    init(startTime: Timecode, endTime: Timecode) {
        start = startTime
        end = endTime
    }
    
    init?(_ description: String) {
        let sample = "00:02:19,482 --> 00:02:21,609"
        
        guard sample.count == description.count else {
            return nil
        }
        
        let parts = description.components(separatedBy: TimeDuration.delimiterBlock)
        guard parts.count == 2, parts[0].count == parts[1].count else {
            return nil
        }
        
        guard let t1 = Timecode(parts[0]), let t2 = Timecode(parts[1]) else {
            return nil
        }
        
        start = t1
        end = t2
    }
    
    var description: String {
        return start.description + TimeDuration.delimiterBlock + end.description
    }
    
    var milliseconds: Int {
        return (end - start).millisecondsValue
    }
    
    static func +(lhs: TimeDuration, rhs: Int) -> TimeDuration {
        return TimeDuration(startTime: lhs.start + rhs, endTime: lhs.end + rhs)
    }
    
    static func -(lhs: TimeDuration, rhs: Int) -> TimeDuration {
        return TimeDuration(startTime: lhs.start - rhs, endTime: lhs.end - rhs)
    }
    
    static func == (lhs: TimeDuration, rhs: TimeDuration) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
    
}


struct Subtitle: Equatable {
    
    static let newline = "\n"
    
    var sequentialNumber: Int
    var time: TimeDuration
    var text: String
    let blank: String = Subtitle.newline
    
    var description: String {
        return String(sequentialNumber) + Subtitle.newline
        + time.description + Subtitle.newline
        + text + blank
    }
    
    static func +(lhs: Subtitle, rhs: Int) -> Subtitle {
        var result = lhs
        result.time = lhs.time + rhs
        return result
    }
    
    static func == (lhs: Subtitle, rhs: Subtitle) -> Bool {
        return lhs.sequentialNumber == rhs.sequentialNumber &&
                lhs.time == rhs.time &&
                lhs.text == rhs.text
    }
    
    func split() -> [Subtitle] {
        let (left, right) = Subtitle.divideText(text: text)
        
        return [Subtitle(sequentialNumber: sequentialNumber, time: time, text: left),
                Subtitle(sequentialNumber: sequentialNumber, time: time, text: right)]
    }
    
    static func divideText(text: String) -> (String, String) {
        var left = ""
        var right = ""
        
        let lines = text.components(separatedBy: CharacterSet.newlines)
        
        switch lines.count {
        case 2:
            left = lines[0] + "\n"
            right = lines[0] + "\n"
        case 3:
            left = lines[0] + "\n"
            right = lines[1] + "\n"
        case 4:
            left = lines[0] + "\n"
            right = lines[1] + lines[2] + "\n"
        case 5:
            left = lines[0] + lines[1] + "\n"
            right = lines[2] + lines[3] + "\n"
        case 6:
            left = lines[0] + lines[1] + lines[2] + "\n"
            right = lines[3] + lines[4] + lines[5] + "\n"
            
        default:
            left = lines[0] + "\n"
            for i in 1 ..< lines.count {
                right += lines[i] + "\n"
            }
        }
        
        return (left, right)
    }
}


struct SubRip: Equatable {
    
    var subtitles: [Subtitle]
    
    init(subs: [Subtitle]) {
        subtitles = subs
    }
    
    init(srtFileContent: String) {
        let sourceLines = srtFileContent.components(separatedBy: CharacterSet.newlines)
        
        // Append 2 fake lines for reducing check last time
        let lines = sourceLines + ["99999", "00:02:19,482 --> 00:02:21,609"]
        
        let (subs, _) = lines.reduce(into: ([Subtitle](), [String]())) { partialResult, line in
            // 0. Caches Lines
            partialResult.1.append(line)
            
            // 1. Detect Timecode
            if nil != TimeDuration(line) {
                // number
                // time
                // xxx
                // number
                // time
                let stripedLines = partialResult.1.filter { s in
                    return s.count > 0
                }
                
                let timeLines = stripedLines.compactMap { s in
                    return TimeDuration(s)
                }
                
                if stripedLines.count >= 5, timeLines.count >= 2 {
                    // 2. Build Subtitle
                    let number = partialResult.0.count + 1
                    let timeDesc = timeLines[0]
                    let text = stripedLines[2..<stripedLines.count-2].reduce(into: "") { p, t in
                        p += t
                        p += "\n"
                    }
                    
                    partialResult.0.append(Subtitle(sequentialNumber: number, time: timeDesc, text: text))
                    
                    // 3. Clear cachedLines
                    partialResult.1.removeAll()
                    partialResult.1.append(contentsOf: stripedLines[(stripedLines.count-2)...])
                }
            }
        }
        
        subtitles = subs
    }
    
    var srtFileContent: String {
        return subtitles.reduce("") { partialResult, s in
            return partialResult + s.description
        }
    }
    
    static func +(lhs: SubRip, rhs: Int) -> SubRip {
        let subs = lhs.subtitles.map { sub in
            return sub + rhs
        }
        
        return SubRip(subs: subs)
    }
    
    func split() -> [SubRip] {
        var left = [Subtitle]()
        var right = [Subtitle]()
        
        subtitles.forEach { sub in
            let splited = sub.split()
            left.append(splited[0])
            right.append(splited[1])
        }
        
        return [SubRip(subs: left),
                SubRip(subs: right)]
    }
}
