//
//  XCTestCase+Snapshot.swift
//  XCTestCase+Snapshot
//
//  Created by Elon on 28/08/2021.
//

import XCTest

extension XCTestCase {
    func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot: snapshot)
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not matched stored snapshot. New snapshot URL: \(temporarySnapshotURL), stored snapshot URL: \(snapshotURL)", file: file, line: line)
            
            return
        }
    }
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot: snapshot)
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            try snapshotData?.write(to: snapshotURL)
            XCTFail("Record succeeded - use `assert` to compare the snapshot from now on", file: file, line: line)
        } catch {
            XCTFail("Failed to record snapshot with error : \(error)", file: file, line: line)
        }
    }
    
    func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    func makeSnapshotData(snapshot: UIImage, file: StaticString = #filePath, line: UInt = #line) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data presentation from snapshot", file: file, line: line)
            return nil
        }
        
        return snapshotData
    }

}
