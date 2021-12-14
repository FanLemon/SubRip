import XCTest
@testable import SubRip


extension TimeIntegerLiteral {
    
    static var maxIntegerValue: Int {
        return Self.numeralBase - 1
    }
    
    static var minIntegerValue: Int {
        return 0
    }
    
    func validateTimeIntegerLiteralEqual(input: Int) throws {
        XCTAssertEqual(integerValue, input)
        
        var label = String(input)
        for _ in 0 ..< Self.literalWidth-label.count {
            label = "0" + label
        }
        XCTAssertEqual(description, label)
    }
    
    static func validateTimeIntegerLiteralMax(input: Int) throws {
        let result = Self.time(value: input)
        
        try result.validateTimeIntegerLiteralEqual(input: Self.maxIntegerValue)
    }
    
    static func validateTimeIntegerLiteralMax(input: String) throws {
        let result = Self.time(str: input)
        
        try result.validateTimeIntegerLiteralEqual(input: Self.maxIntegerValue)
    }
    
    static func validateTimeIntegerLiteralMin(input: Int) throws {
        let result = Self.time(value: input)
        
        try result.validateTimeIntegerLiteralEqual(input: Self.minIntegerValue)
    }
    
    static func validateTimeIntegerLiteralMin(input: String) throws {
        let result = Self.time(str: input)
        
        try result.validateTimeIntegerLiteralEqual(input: Self.minIntegerValue)
    }
    
    static func validateTimeIntegerLiteralNormal(input: Int) throws {
        let result = Self.time(value: input)
        
        try result.validateTimeIntegerLiteralEqual(input: input)
    }
    
    static func validateTimeIntegerLiteralNormal(input: String) throws {
        let result = Self.time(str: input)
        
        try result.validateTimeIntegerLiteralEqual(input: Int(input) ?? 0)
    }
    
    static func testTimeIntegerLiteral() throws {
        try Self.validateTimeIntegerLiteralMin(input: -3)
        try Self.validateTimeIntegerLiteralMin(input: 0)
        try Self.validateTimeIntegerLiteralNormal(input: Int.random(in: 1 ..< Self.numeralBase))
        try Self.validateTimeIntegerLiteralNormal(input: Int.random(in: 1 ..< Self.numeralBase))
        try Self.validateTimeIntegerLiteralNormal(input: Int.random(in: 1 ..< Self.numeralBase))
        try Self.validateTimeIntegerLiteralMax(input: Self.numeralBase)
        try Self.validateTimeIntegerLiteralMax(input: Self.numeralBase + 13)
        
        try Self.validateTimeIntegerLiteralMin(input: "")
        try Self.validateTimeIntegerLiteralMin(input: "a")
        try Self.validateTimeIntegerLiteralMin(input: "fdjsaklf")
        try Self.validateTimeIntegerLiteralMin(input: "-4")
        try Self.validateTimeIntegerLiteralMin(input: "0")
        try Self.validateTimeIntegerLiteralNormal(input: String(Int.random(in: 1 ..< Self.numeralBase)))
        try Self.validateTimeIntegerLiteralNormal(input: String(Int.random(in: 1 ..< Self.numeralBase)))
        try Self.validateTimeIntegerLiteralNormal(input: String(Int.random(in: 1 ..< Self.numeralBase)))
        try Self.validateTimeIntegerLiteralMax(input: String(Self.numeralBase))
        try Self.validateTimeIntegerLiteralMax(input: String(Self.numeralBase + 13))
    }
}



enum SubRipTestsError: Error {
    
    case encounteredNil
}


final class SubRipTests: XCTestCase {

    func testTimeIntegerLiteral() throws {
        try TimeNumeraBase24.testTimeIntegerLiteral()
        try TimeNumeraBase60.testTimeIntegerLiteral()
        try TimeNumeraBase1000.testTimeIntegerLiteral()
    }
    
    func testTimecode() throws {
        var sample = "00:03:18,608"

        guard let t1 = Timecode(sample) else {
            throw SubRipTestsError.encounteredNil
        }
        
        let t2 = Timecode(milliseconds: t1.millisecondsValue)
        XCTAssertEqual(t1, t2)
        
        
        sample = "00:03:18608"
        XCTAssertNil(Timecode(sample))
        
        
        sample = "00:03:18:608"
        XCTAssertNil(Timecode(sample))
        
        
        sample = "00,03,18:608"
        XCTAssertNil(Timecode(sample))
        
        
        let t3 = t1 + 392
        guard let t4 = Timecode(t3.description) else {
            throw SubRipTestsError.encounteredNil
        }
        XCTAssertEqual(t3, t4)
        let t5 = t4 - 392
        XCTAssertEqual(t1, t5)
    }
    
    func testTimeduration() throws {
        var sample = "00:02:19,482 --> 00:02:21,609"
        
        guard let td1 = TimeDuration(sample) else {
            throw SubRipTestsError.encounteredNil
        }
        
        let td2 = TimeDuration(startTime: td1.start + 3845923 - 3845923, endTime: td1.end + 3845923 - 3845923)
        XCTAssertEqual(td1, td2)
        
        sample = "00:02:19,482 -->00:02:21,609"
        XCTAssertNil(TimeDuration(sample))
        
        sample = "00:02:19,482 --- 00:02:21,609"
        XCTAssertNil(TimeDuration(sample))
        
        sample = "00:02:19,482 <-- 00:02:21,609"
        XCTAssertNil(TimeDuration(sample))
    }
    
    func testSubRip() throws {
        let sample = """
        12
        00:00:55,184 --> 00:00:57,167
        饿了的话就到我家来
        Come to the house if you're hungry.

        2
        00:01:14,805 --> 00:01:16,738
        谢谢
        
         Thank you.

        3
        00:01:16,738 --> 00:01:19,293
        嘿 帽子摘了
         Hey. Take your hat off.

        4
        00:01:19,293 --> 00:01:21,019
        噢
         Oh. Sh

        
        
        
        
        5
        00:01:39,347 --> 00:01:41,085
         谢谢你 亲爱的 不客气
         Thank you, darling.  You're welcome.

        6
        00:01:41,125 --> 00:01:42,557
         祝你今天愉快 你也是
         Have a good day.  You, too.

        7
        00:01:44,352 --> 00:01:46,984
         吉米 你准备好了吗?
         Jimmy  you ready?

        8
        00:01:50,393 --> 00:01:52,432
        噢 准备好了 那行 走吧
         Uh, yeah.  All right, let's go.

        91
        00:01:57,641 --> 00:01:59,229
         谢谢你 女士 不客气
         Thank you, Ma'am.  You're welcome.

        10
        00:02:06,064 --> 00:02:07,789
        你骑的那匹马咋样了？
         How's the one you rode in on?

        11
        00:02:07,789 --> 00:02:10,482
        还没真正驯服 我记得它才两岁
         Not real broke. I think they said he's just two.

        12
        00:02:14,175 --> 00:02:16,143
        我说了 它还没真正驯服呢
        I said he's not real broke.

        13
        00:02:16,143 --> 00:02:18,135
        我们这卖的都是驯服过的 吉米
         We sell the broke ones around here, Jimmy.

        14
        
        00:03:05,975 --> 00:03:07,488
        妈妈!
        Mama!

        15
        00:04:02,282 --> 00:04:04,282
        翻译：业余渣翻人

        16
        00:04:17,678 --> 00:04:18,886
        起这么早干什么?
         What are you doing up?

        17
        00:04:18,886 --> 00:04:21,785
         我爸还没回我电话
         My father hasn't called me back.

        18
        00:04:21,785 --> 00:04:23,166
        我有点担心
        Worries me.
        """
        
        var index: Int = 0
        let subrip = SubRip(srtFileContent: sample)
        subrip.subtitles.forEach { sub in
            //print(sub.description, terminator: "")
            
            index += 1
            XCTAssertEqual(sub.sequentialNumber, index)
        }
        XCTAssertEqual(subrip.subtitles.count, 18)
        
        let shiftMilliseconds: Int = 83947
        let shifted = subrip + shiftMilliseconds
        let rollback = shifted + (-shiftMilliseconds)
        
        
        XCTAssertEqual(subrip, rollback)
        
        let splited = subrip.split()
        XCTAssertEqual(splited[0].subtitles.count, splited[1].subtitles.count)
        
    }
}
