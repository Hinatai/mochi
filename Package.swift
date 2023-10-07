// swift-tools-version: 5.7
// This file is auto-generated. Do not edit this file directly. Instead, make changes in `Package/` directory and then run `package.sh` to generate a new `Package.swift` file.
//
// Array+Depedencies.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension Array: Dependencies where Element == Dependency {
  func appending(_ dependencies: any Dependencies) -> [Dependency] {
    self + dependencies
  }
}
//
// Array+SupportedPlatforms.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension Array: SupportedPlatforms where Element == SupportedPlatform {
  func appending(_ platforms: any SupportedPlatforms) -> Self {
    self + .init(platforms)
  }
}
//
// Array+TestTargets.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension Array: TestTargets where Element == TestTarget {
  func appending(_ testTargets: any TestTargets) -> [TestTarget] {
    self + testTargets
  }
}
//
//  CSettingsBuilder.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

@resultBuilder
enum CSettingsBuilder {
  static func buildPartialBlock(first: CSetting) -> [CSetting] {
    [first]
  }

  static func buildPartialBlock(accumulated: [CSetting], next: CSetting) -> [CSetting] {
    accumulated + [next]
  }
}
//
// Dependencies.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol Dependencies: Sequence where Element == Dependency {
  // swiftlint:disable:next identifier_name
  init<S>(_ s: S) where S.Element == Dependency, S: Sequence
  func appending(_ dependencies: any Dependencies) -> Self
}
//
// Dependency.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol Dependency {
  var targetDepenency: _PackageDescription_TargetDependency { get }
}
//
// DependencyBuilder.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

@resultBuilder
enum DependencyBuilder {
  static func buildPartialBlock(first: Dependency) -> any Dependencies {
    [first]
  }

  static func buildPartialBlock(accumulated: any Dependencies, next: Dependency) -> any Dependencies {
    accumulated + [next]
  }
}
//
// LanguageTag.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension LanguageTag {
  static let english: LanguageTag = "en"
}
//
// Package+Extensions.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension Package {
  convenience init(
    name: String? = nil,
    @ProductsBuilder entries: @escaping () -> [Product],
    @TestTargetBuilder testTargets: @escaping () -> any TestTargets = { [TestTarget]() },
    @SwiftSettingsBuilder swiftSettings: @escaping () -> [SwiftSetting] = { [SwiftSetting]() }
  ) {
    let packageName: String
    if let name {
      packageName = name
    } else {
      var pathComponents = #filePath.split(separator: "/")
      pathComponents.removeLast()
      // swiftlint:disable:next force_unwrapping
      packageName = String(pathComponents.last!)
    }
    let allTestTargets = testTargets()
    let entries = entries()
    let products = entries.map(_PackageDescription_Product.entry)
    var targets = entries.flatMap(\.productTargets)
    let allTargetsDependencies = targets.flatMap { $0.allDependencies() }
    let allTestTargetsDependencies = allTestTargets.flatMap { $0.allDependencies() }
    let dependencies = allTargetsDependencies + allTestTargetsDependencies
    let targetDependencies = dependencies.compactMap { $0 as? Target }
    let packageDependencies = dependencies.compactMap { $0 as? PackageDependency }
    targets += targetDependencies
    targets += allTestTargets.map { $0 as Target }
    assert(targetDependencies.count + packageDependencies.count == dependencies.count)

    let packgeTargets = Dictionary(
      grouping: targets,
      by: { $0.name }
    )
    .values
    .compactMap(\.first)
    .map { _PackageDescription_Target.entry($0, swiftSettings: swiftSettings()) }

    let packageDeps = Dictionary(
      grouping: packageDependencies,
      by: { $0.productName }
    ).values.compactMap(\.first).map(\.dependency)

    self.init(name: packageName, products: products, dependencies: packageDeps, targets: packgeTargets)
  }
}

extension Package {
  func supportedPlatforms(
    @SupportedPlatformBuilder supportedPlatforms: @escaping () -> any SupportedPlatforms
  ) -> Package {
    self.platforms = .init(supportedPlatforms())
    return self
  }

  func defaultLocalization(_ defaultLocalization: LanguageTag) -> Package {
    self.defaultLocalization = defaultLocalization
    return self
  }
}
//
// PackageDependency.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

import PackageDescription

protocol PackageDependency: Dependency {
  var packageName: String { get }
  var dependency: _PackageDescription_PackageDependency { get }
}

extension PackageDependency {
  var productName: String {
    "\(Self.self)"
  }
  
  var packageName : String {
    switch self.dependency.kind {
    case let .sourceControl(name: name, location: location, requirement: _):
      return name ?? location.packageName ?? productName
    case let .fileSystem(name: name, path: path):
      return name ?? path.packageName ?? productName
    case let .registry(id: id, requirement: _):
      return id
    @unknown default:
      return productName
    }
  }

  var targetDepenency: _PackageDescription_TargetDependency {
    switch self.dependency.kind {
    case let .sourceControl(name: name, location: location, requirement: _):
      let packageName = name ?? location.packageName
      return .product(name: productName, package: packageName)

    default:
      return .byName(name: productName)
    }
  }
}
//
// PackageDescription.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

// swiftlint:disable type_name

import PackageDescription

typealias _PackageDescription_Product = PackageDescription.Product
typealias _PackageDescription_Target = PackageDescription.Target
typealias _PackageDescription_TargetDependency = PackageDescription.Target.Dependency
typealias _PackageDescription_PackageDependency = PackageDescription.Package.Dependency
//
// PlatformSet.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol PlatformSet {
  @SupportedPlatformBuilder
  var body: any SupportedPlatforms { get }
}
//
// Product+Target.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension Product where Self: Target {
  var productTargets: [Target] {
    [self]
  }

  var targetType: TargetType {
    switch self.productType {
    case .library:
      return .regular

    case .executable:
      return .executable
    }
  }
}
//
// Product.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol Product: _Named {
  var productTargets: [Target] { get }
  var productType: ProductType { get }
}

extension Product {
  var productType: ProductType {
    .library
  }
}
//
// ProductType.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

enum ProductType {
  case library
  case executable
}
//
// ProductsBuilder.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

@resultBuilder
enum ProductsBuilder {
  static func buildPartialBlock(first: Product) -> [Product] {
    [first]
  }

  static func buildPartialBlock(accumulated: [Product], next: Product) -> [Product] {
    accumulated + [next]
  }
}
//
// ResourcesBuilder.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

@resultBuilder
enum ResourcesBuilder {
  static func buildPartialBlock(first: Resource) -> [Resource] {
    [first]
  }

  static func buildPartialBlock(accumulated: [Resource], next: Resource) -> [Resource] {
    accumulated + [next]
  }
}
//
// String.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension String {
  var packageName: String? {
    self.split(separator: "/").last?.split(separator: ".").first.map(String.init)
  }
}
//
// SupportedPlatformBuilder.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

import PackageDescription

@resultBuilder
enum SupportedPlatformBuilder {
  static func buildPartialBlock(first: SupportedPlatform) -> any SupportedPlatforms {
    [first]
  }

  static func buildPartialBlock(first: PlatformSet) -> any SupportedPlatforms {
    first.body
  }

  static func buildPartialBlock(first: any SupportedPlatforms) -> any SupportedPlatforms {
    first
  }

  static func buildPartialBlock(
    accumulated: any SupportedPlatforms,
    next: any SupportedPlatforms
  ) -> any SupportedPlatforms {
    accumulated.appending(next)
  }

  static func buildPartialBlock(
    accumulated: any SupportedPlatforms,
    next: SupportedPlatform
  ) -> any SupportedPlatforms {
    accumulated.appending([next])
  }
}
//
// SupportedPlatforms.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol SupportedPlatforms: Sequence where Element == SupportedPlatform {
  // swiftlint:disable:next identifier_name
  init<S>(_ s: S) where S.Element == SupportedPlatform, S: Sequence
  func appending(_ platforms: any SupportedPlatforms) -> Self
}
//
// SwiftSettingsBuilder.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

@resultBuilder
enum SwiftSettingsBuilder {
  static func buildPartialBlock(first: SwiftSetting) -> [SwiftSetting] {
    [first]
  }

  static func buildPartialBlock(accumulated: [SwiftSetting], next: SwiftSetting) -> [SwiftSetting] {
    accumulated + [next]
  }
}
//
// Target.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol Target: _Depending, Dependency, _Named, _Path {
  var targetType: TargetType { get }

  @CSettingsBuilder
  var cSettings: [CSetting] { get }

  @SwiftSettingsBuilder
  var swiftSettings: [SwiftSetting] { get }

  @ResourcesBuilder
  var resources: [Resource] { get }
}

extension Target {
  var targetType: TargetType {
    .regular
  }

  var targetDepenency: _PackageDescription_TargetDependency {
    .target(name: self.name)
  }

  var cSettings: [CSetting] {
    []
  }

  var swiftSettings: [SwiftSetting] {
    []
  }

  var resources: [Resource] {
    []
  }
}
//
// TargetType.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

//typealias TargetType = Target.TargetType

enum TargetType {
  case regular
  case executable
  case test
  case binary(BinaryTarget)

  enum BinaryTarget {
    case path(String)
    case remote(url: String, checksum: String)
  }
}
//
// TestTarget.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol TestTarget: Target {}

extension TestTarget {
  var targetType: TargetType {
    .test
  }
}
//
// TestTargetBuilder.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

@resultBuilder
enum TestTargetBuilder {
  static func buildPartialBlock(first: TestTarget) -> any TestTargets {
    [first]
  }

  static func buildPartialBlock(accumulated: any TestTargets, next: TestTarget) -> any TestTargets {
    accumulated + [next]
  }
}
//
// TestTargets.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol TestTargets: Sequence where Element == TestTarget {
  // swiftlint:disable:next identifier_name
  init<S>(_ s: S) where S.Element == TestTarget, S: Sequence
  func appending(_ testTargets: any TestTargets) -> Self
}
//
// _Depending.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol _Depending {
  @DependencyBuilder
  var dependencies: any Dependencies { get }
}

extension _Depending {
  var dependencies: any Dependencies {
    [Dependency]()
  }
}

extension _Depending {
  func allDependencies() -> [Dependency] {
    self.dependencies.compactMap {
      $0 as? _Depending
    }
    .flatMap {
      $0.allDependencies()
    }
    .appending(self.dependencies)
  }
}
//
// _Named.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol _Named {
  var name: String { get }
}

extension _Named {
  var name: String {
    "\(Self.self)"
  }
}
//
// _PackageDescription_Product.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension _PackageDescription_Product {
  static func entry(_ entry: Product) -> _PackageDescription_Product {
    let targets = entry.productTargets.map(\.name)

    switch entry.productType {
    case .executable:
      return Self.executable(name: entry.name, targets: targets)

    case .library:
      return Self.library(name: entry.name, targets: targets)
    }
  }
}
//
// _PackageDescription_Target.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension _PackageDescription_Target {
  static func entry(_ entry: Target, swiftSettings: [SwiftSetting] = []) -> _PackageDescription_Target {
    let dependencies = entry.dependencies.map(\.targetDepenency)
    switch entry.targetType {
    case .executable:
      return .executableTarget(
        name: entry.name,
        dependencies: dependencies,
        path: entry.path,
        resources: entry.resources,
        cSettings: entry.cSettings,
        swiftSettings: swiftSettings + entry.swiftSettings
      )

    case .regular:
      return .target(
        name: entry.name,
        dependencies: dependencies,
        path: entry.path,
        resources: entry.resources,
        cSettings: entry.cSettings,
        swiftSettings: swiftSettings + entry.swiftSettings
      )

    case .test:
      return .testTarget(
        name: entry.name,
        dependencies: dependencies,
        path: entry.path,
        resources: entry.resources,
        cSettings: entry.cSettings,
        swiftSettings: swiftSettings + entry.swiftSettings
      )

    case .binary(.path(let path)):
      return .binaryTarget(
        name: entry.name,
        path: path
      )

    case .binary(.remote(let url, let checksum)):
      return .binaryTarget(
        name: entry.name,
        url: url,
        checksum: checksum
      )
    }
  }
}
//
//  _Path.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

protocol _Path {
  var path: String? { get }
}

extension _Path {
  var path: String? { nil }
}
//
//  File.swift
//  
//
//  Created by ErrorErrorError on 10/4/23.
//  
//

import Foundation

struct AnalyticsClient: Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
    }
}
//
//  Build.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct Build: Client {
    var dependencies: any Dependencies {
        Semver()
        ComposableArchitecture()
    }
}
//
//  DatabaseClient.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct DatabaseClient: Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
        Semver()
        Tagged()
    }

    var resources: [Resource] {
        Resource.copy("Resources/MochiSchema.xcdatamodeld")
    }
}
//
//  FileClient.swift
//  
//
//  Created by ErrorErrorError on 10/6/23.
//  
//

struct FileClient: Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
    }
}
//
//  LoggerClient.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct LoggerClient: Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
    }
}
//
//  ModuleClient.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct ModuleClient: Client {
    var dependencies: any Dependencies {
        DatabaseClient()
        FileClient()
        SharedModels()
        WasmInterpreter()
        Tagged()
        ComposableArchitecture()
        SwiftSoup()
        Semaphore()
    }
}
//
//  PlayerClient.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct PlayerClient: Client {
    var dependencies: any Dependencies {
        Architecture()
        DatabaseClient()
        ModuleClient()
        SharedModels()
        Styling()
        UserDefaultsClient()
        ComposableArchitecture()
        ViewComponents()
    }
}
//
//  RepoClient.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct RepoClient: Client {
    var dependencies: any Dependencies {
        DatabaseClient()
        FileClient()
        SharedModels()
        TOMLDecoder()
        Tagged()
        ComposableArchitecture()
    }
}
//
//  UserDefaultsClient.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct UserDefaultsClient: Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
    }
}
//
//  File.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct UserSettingsClient: Client {
    var dependencies: any Dependencies {
        UserDefaultsClient()
        ComposableArchitecture()
    }
}
//
//  File.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

protocol Client: Target {}

extension Client {
    var path: String? {
        "Sources/Clients/\(self.name)"
    }
}
//
//  ComposableArchitecture.swift
//  
//
//  Created by ErrorErrorError on 10/4/23.
//  
//

struct ComposableArchitecture: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.1.0")
    }
}
//
//  Nuke.swift
//  
//
//  Created by ErrorErrorError on 10/4/23.
//  
//

struct Nuke: PackageDependency {
    static let nukeURL = "https://github.com/kean/Nuke.git"
    static let nukeVersion: Version = "12.1.5"

    var dependency: Package.Dependency {
        .package(url: Self.nukeURL, exact: Self.nukeVersion)
    }
}

struct NukeUI: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: Nuke.nukeURL, exact: Nuke.nukeVersion)
    }
}
//
//  Semaphore.swift
//  
//
//  Created by ErrorErrorError on 10/4/23.
//  
//

struct Semaphore: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/groue/Semaphore", exact: "0.0.8")
    }
}
//
//  Semver.swift
//  
//
//  Created by ErrorErrorError on 10/4/23.
//  
//

struct Semver: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/kutchie-pelaez/Semver.git", exact: "1.0.0")
    }
}
//
//  SwiftSoup.swift
//  
//
//  Created by ErrorErrorError on 10/4/23.
//  
//

struct SwiftSoup: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0")
    }
}
//
//  SwiftUIBackports.swift
//  
//
//  Created by ErrorErrorError on 10/4/23.
//  
//

struct SwiftUIBackports: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/shaps80/SwiftUIBackports.git", .upToNextMajor(from: "2.0.0"))
    }
}
//
//  TOMLDecoder.swift
//  
//
//  Created by ErrorErrorError on 10/4/23.
//  
//

struct TOMLDecoder: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/dduan/TOMLDecoder", from: "0.2.2")
    }
}
//
//  File.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct Tagged: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/pointfreeco/swift-tagged", exact: "0.10.0")
    }
}
//
//  Discover.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct Discover: Feature {
    var dependencies: any Dependencies {
        Architecture()
        PlaylistDetails()
        ModuleClient()
        ModuleLists()
        RepoClient()
        Search()
        Styling()
        SharedModels()
        ViewComponents()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  MochiApp.swift
//  
//
//  Created by ErrorErrorError on 10/4/23.
//  
//

import Foundation

struct MochiApp: Product, Target {
    var name: String {
        "App"
    }

    var path: String? {
        "Sources/Features/\(self.name)"
    }

    var dependencies: any Dependencies {
        Architecture()
        Discover()
        Repos()
        Settings()
        SharedModels()
        Styling()
        UserSettingsClient()
        VideoPlayer()
        ViewComponents()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  ModuleLists.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct ModuleLists: Feature {
    var dependencies: any Dependencies {
        Architecture()
        RepoClient()
        Styling()
        SharedModels()
        ViewComponents()
        ComposableArchitecture()
    }
}
//
//  PlaylistDetails.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct PlaylistDetails: Feature {
    var dependencies: any Dependencies {
        Architecture()
        ContentCore()
        RepoClient()
        LoggerClient()
        ModuleClient()
        RepoClient()
        Styling()
        SharedModels()
        ViewComponents()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  Repos.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct Repos: Feature {
    var dependencies: any Dependencies {
        Architecture()
        ModuleClient()
        RepoClient()
        SharedModels()
        Styling()
        ViewComponents()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  Search.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct Search: Feature {
    var dependencies: any Dependencies {
        Architecture()
        LoggerClient()
        ModuleClient()
        ModuleLists()
        PlaylistDetails()
        RepoClient()
        SharedModels()
        Styling()
        ViewComponents()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  Settings.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

struct Settings: Feature {
    var dependencies: any Dependencies {
        Architecture()
        Build()
        SharedModels()
        Styling()
        ViewComponents()
        UserSettingsClient()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  VideoPlayer.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

struct VideoPlayer: Feature {
    var dependencies: any Dependencies {
        Architecture()
        ContentCore()
        LoggerClient()
        PlayerClient()
        SharedModels()
        Styling()
        ViewComponents()
        UserSettingsClient()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  File.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

protocol Feature: Product, Target {}

extension Feature {
    var path: String? {
        "Sources/Features/\(self.name)"
    }
}
//
//  MochiPlatforms.swift
//  
//
//  Created by ErrorErrorError on 10/4/23.
//  
//

import Foundation

import PackageDescription

struct MochiPlatforms: PlatformSet {
    var body: any SupportedPlatforms {
        SupportedPlatform.macOS(.v12)
        SupportedPlatform.iOS(.v15)
    }
}
//
//  Architecture.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

struct Architecture: Shared {
    var dependencies: any Dependencies {
        FoundationHelpers()
        ComposableArchitecture()
    }
}
//
//  ContentCore.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct ContentCore: Shared {
    var dependencies: any Dependencies {
        Architecture()
        FoundationHelpers()
        ModuleClient()
        LoggerClient()
        Tagged()
        ComposableArchitecture()
    }
}
//
//  FoundationHelpers.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

struct FoundationHelpers: Shared {}
//
//  SharedModels.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct SharedModels: Shared {
    var dependencies: any Dependencies {
        DatabaseClient()
        Tagged()
        ComposableArchitecture()
        Semver()
    }
}
//
//  File.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct Styling: Shared {
    var dependencies: any Dependencies {
        ViewComponents()
        ComposableArchitecture()
        Tagged()
        SwiftUIBackports()
    }
}
//
//  File.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct ViewComponents: Shared {
    var dependencies: any Dependencies {
        SharedModels()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  File.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

struct WasmInterpreter: Shared {
    var dependencies: any Dependencies {
        CWasm3()
    }

    var cSettings: [CSetting] {
        CSetting.define("APPLICATION_EXTENSION_API_ONLY", to: "YES")
    }
}

struct CWasm3: Product, Target {
    var targetType: TargetType {
        .binary(
            .remote(
                url: "https://github.com/shareup/cwasm3/releases/download/v0.5.2/CWasm3-0.5.0.xcframework.zip",
                checksum: "a2b0785be1221767d926cee76b087f168384ec9735b4f46daf26e12fae2109a3"
            )
        )
    }
}
//
//  File.swift
//  
//
//  Created by ErrorErrorError on 10/5/23.
//  
//

import Foundation

protocol Shared: Product, Target {}

extension Shared {
    var path: String? {
        "Sources/Shared/\(self.name)"
    }
}
//
//  Index.swift
//  
//
//  Created by ErrorErrorError on 10/4/23.
//  
//

import Foundation

let package = Package {
    ModuleLists()
    PlaylistDetails()
    Discover()
    Repos()
    Search()
    Settings()
    VideoPlayer()

    MochiApp()
}
.supportedPlatforms {
    MochiPlatforms()
}
