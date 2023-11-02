//
//  CollectionLoadingState.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/30.
//

import Foundation
import ComposableArchitecture
import Combine

enum CollectionLoadingState<Content: Equatable>: Equatable {
    static func == (lhs: CollectionLoadingState<Content>, rhs: CollectionLoadingState<Content>) -> Bool {
        switch (lhs, rhs) {
        case (.loaded(let content), .loaded(let rhsContent)):
            return content == rhsContent
        case (.loading(let placeholder), .loading(let rhsPlaceholder)):
            return placeholder == rhsPlaceholder
        case (.empty, .empty):
            return true
        case (.error, .error):
            return true
        case (.unload, .unload):
            return true
        default:
            return false
        }
    }
    
    
  case loading(placeholder: Content), loaded(content: Content), empty, error(Error), unload
}





