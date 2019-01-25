//
//  ViewController.swift
//  Movs
//
//  Created by Filipe Jordão on 22/01/19.
//  Copyright © 2019 Filipe Jordão. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PopularMoviesViewController: UIViewController {
    private lazy var collectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: collectionLayout())
    }()
    var coordinator: PopularMoviesCoordinator?

    private let disposeBag = DisposeBag()

    override func loadView() {
        super.loadView()
        title = "Popular"

        view = collectionView
        view.backgroundColor = .white

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        collectionView.register(PopularMovieCell.self, forCellWithReuseIdentifier: PopularMovieCell.reuseId)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.rx.setDelegate(self)
                         .disposed(by: disposeBag)
    }
}

extension PopularMoviesViewController: MoviesViewModelInput, MoviesViewModelOutput {
    func requestUpdate() -> Driver<Void> {
        return willAppearBind()
            .asDriver { _ in Driver<Void>.empty() }
    }

    func willAppearBind() -> Observable<Void> {
        return rx.sentMessage(#selector(viewWillAppear)).map { _ in Void() }
    }

    func requestContent() -> Driver<Void> {
        return collectionView.isNearBottom()
                             .filter { $0 == true }
                             .map { _ in Void() }
                             .asDriver(onErrorJustReturn: Void())
    }

    func display(error: Driver<Void>) {

    }

    func display(movies: Driver<[MovieViewModel]>) {
        movies.drive(collectionView.rx.items(cellIdentifier: PopularMovieCell.reuseId,
                                             cellType: PopularMovieCell.self),
                     curriedArgument: setupCell)
              .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .debug("selected")
            .map {idx -> MovieViewModel? in
            guard let cell = self.collectionView.cellForItem(at: idx) as? PopularMovieCell else { return nil }

            return cell.viewModel
        }
        .subscribe(onNext: {[weak self] viewModel in
            guard let strongSelf = self else { return }
            strongSelf.coordinator?.next(on: strongSelf, with: viewModel!)
        })
        .disposed(by: disposeBag)
    }

    func setupCell(idx: Int, viewModel: MovieViewModel, cell: PopularMovieCell) {
        cell.setup(with: viewModel)
    }

    func collectionLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        return layout
    }
}

extension PopularMoviesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width / 2) - 10
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
}
