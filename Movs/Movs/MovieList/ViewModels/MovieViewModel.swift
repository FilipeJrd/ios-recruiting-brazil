//
//  MovieViewModel.swift
//  Movs
//
//  Created by Filipe Jordão on 22/01/19.
//  Copyright © 2019 Filipe Jordão. All rights reserved.
//

import Foundation

struct MovieViewModel {
    let model: Movie
    let title: String
    let image: URL?
    var isFavorite: Bool
}
