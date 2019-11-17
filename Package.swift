// swift-tools-version:5.0
//  Package.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import PackageDescription

let package = Package(
    name: "HealthDataSync",
	platforms: [
        .iOS(.v11)
	],
    products: [
        .library(
            name: "HealthDataSync",
            targets: ["HealthDataSync"]),
    ],
    targets: [
        .target(
            name: "HealthDataSync",
            path: "Sources"),
    ]
)
