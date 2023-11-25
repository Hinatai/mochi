//
//  AppFeatureView+macOS.swift
//
//
//  Created by ErrorErrorError on 11/23/23.
//  
//

import Architecture
import ComposableArchitecture
import Discover
import Foundation
import Repos
import Styling
import SwiftUI
import VideoPlayer

#if os(macOS)
extension AppFeature.View: View {
    @MainActor
    public var body: some View {
        NavigationView {
            WithViewStore(store, observe: \.selected) { viewStore in
                List {
                    ForEach(AppFeature.State.Tab.allCases.filter(\.self != .settings), id: \.rawValue) { tab in
                        NavigationLink(
                            tag: tab,
                            selection: viewStore.binding(
                                get: { tab == $0 ? tab : nil },
                                send: .view(.didSelectTab(tab))
                            )
                        ) {
                            switch tab {
                            case .discover:
                                DiscoverFeature.View(
                                    store: store.scope(
                                        state: \.discover,
                                        action: Action.InternalAction.discover
                                    )
                                )
                            case .repos:
                                ReposFeature.View(
                                    store: store.scope(
                                        state: \.repos,
                                        action: Action.InternalAction.repos
                                    )
                                )
                            case .settings:
                                EmptyView()
                            }
                        } label: {
                            Label(tab.rawValue, systemImage: tab.image)
                        }
                    }
                }
                .listStyle(.sidebar)
            }

            Text("haha this is not supposed to occur")
        }
        .window(
            store: store.scope(
                state: \.$videoPlayer,
                action: Action.InternalAction.videoPlayer
            ),
            content: VideoPlayerFeature.View.init
        )
    }
}
#endif