// RUN: %{swiftc} %s -o %{built_tests_dir}/Asynchronous-Predicates
// RUN: %{built_tests_dir}/Asynchronous-Predicates > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
    import Foundation
#else
    import SwiftXCTest
    import SwiftFoundation
#endif

// CHECK: Test Suite 'All tests' started at \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'PredicateExpectationsTestCase' started at \d+:\d+:\d+\.\d+
class PredicateExpectationsTestCase: XCTestCase {
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTruePredicateAndObject_passes' started at \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTruePredicateAndObject_passes' passed \(\d+\.\d+ seconds\).
    func test_immediatelyTruePredicateAndObject_passes() {
        let predicate = NSPredicate(value: true)
        let object = NSObject()
        expectation(for: predicate, evaluatedWith: object)
        waitForExpectations(withTimeout: 0.1)
    }

    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyFalsePredicateAndObject_fails' started at \d+:\d+:\d+\.\d+
    // CHECK: .*/Tests/Functional/Asynchronous/Predicates/Expectations/main.swift:[[@LINE+6]]: error: PredicateExpectationsTestCase.test_immediatelyFalsePredicateAndObject_fails : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: Expect `<NSPredicate: 0x[0-9A-Fa-f]{1,16}>` for object <NSObject: 0x[0-9A-Fa-f]{1,16}>
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyFalsePredicateAndObject_fails' failed \(\d+\.\d+ seconds\).
    func test_immediatelyFalsePredicateAndObject_fails() {
        let predicate = NSPredicate(value: false)
        let object = NSObject()
        expectation(for: predicate, evaluatedWith: object)
        waitForExpectations(withTimeout: 0.1)
    }

    // CHECK: Test Case 'PredicateExpectationsTestCase.test_delayedTruePredicateAndObject_passes' started at \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_delayedTruePredicateAndObject_passes' passed \(\d+\.\d+ seconds\).
    func test_delayedTruePredicateAndObject_passes() {
        let halfSecLaterDate = NSDate(timeIntervalSinceNow: 0.01)
        let predicate = NSPredicate(block: {
            evaluatedObject, bindings in
            if let evaluatedDate = evaluatedObject as? NSDate {
                return evaluatedDate.compare(NSDate()) == NSComparisonResult.orderedAscending
            }
            return false
        })
        expectation(for: predicate, evaluatedWith: halfSecLaterDate)
        waitForExpectations(withTimeout: 0.1)
    }
    
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTrueDelayedFalsePredicateAndObject_passes' started at \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTrueDelayedFalsePredicateAndObject_passes' passed \(\d+\.\d+ seconds\).
    func test_immediatelyTrueDelayedFalsePredicateAndObject_passes() {
        let halfSecLaterDate = NSDate(timeIntervalSinceNow: 0.01)
        let predicate = NSPredicate(block: { evaluatedObject, bindings in
            if let evaluatedDate = evaluatedObject as? NSDate {
                return evaluatedDate.compare(NSDate()) == NSComparisonResult.orderedDescending
            }
            return false
        })
        expectation(for: predicate, evaluatedWith: halfSecLaterDate)
        waitForExpectations(withTimeout: 0.1)
    }
    
    static var allTests: [(String, (PredicateExpectationsTestCase) -> () throws -> Void)] {
        return [
                   ("test_immediatelyTruePredicateAndObject_passes", test_immediatelyTruePredicateAndObject_passes),
                   ("test_immediatelyFalsePredicateAndObject_fails", test_immediatelyFalsePredicateAndObject_fails),
                   ("test_delayedTruePredicateAndObject_passes", test_delayedTruePredicateAndObject_passes),
                   ("test_immediatelyTrueDelayedFalsePredicateAndObject_passes", test_immediatelyTrueDelayedFalsePredicateAndObject_passes),
        ]
    }
}

// CHECK: Test Suite 'PredicateExpectationsTestCase' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 4 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
XCTMain([testCase(PredicateExpectationsTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 4 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 4 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
