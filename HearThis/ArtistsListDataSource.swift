//
//  ArtistsListDataSource.swift
//  HearThis
//
//  Created by Manuel Meyer on 17.11.16.
//  Copyright © 2016 Manuel Meyer. All rights reserved.
//

import UIKit
import OFAPopulator

class ArtistsDataProvider:NSObject, OFASectionDataProvider {
    init(artistsResource: ArtistsResourceType, reload: @escaping ()-> Void) {
        self.reload = reload
        self.artistsResource = artistsResource
        super.init()
        fetch()
    }
    
    var sectionObjects: [Any]! = []
    let reload: () -> Void
    private let artistsResource: ArtistsResourceType
    
    private func fetch(){
        artistsResource.topArtists {
            [weak self]
            (result) in
            guard let `self` = self else { return }
            switch result {
            case .success(let artists):
                self.sectionObjects = artists
            case .error(let error):
                print(error)
            }
            self.reload()
        }
    }

}

@objc
protocol ArtistSelectionObserver: class {
    func selected(_ artist: Artist, on: IndexPath)
}


class ArtistsListDatasource {

    init(tableView: UITableView, artistsResource: ArtistsResourceType) throws {
        self.tableView = tableView
        self.artistsResource = artistsResource
        try configure()
    }
    
    private weak var artistsResource: ArtistsResourceType?
    private weak var tableView: UITableView?
    private var populator: OFAViewPopulator?
    
    private var selectionObservers = NSHashTable<ArtistSelectionObserver>.weakObjects()
    func registerSelectionObserver(observer: ArtistSelectionObserver) {
        selectionObservers.add(observer)
    }
    
    private func configure() throws {
        
        if let artistsResource = self.artistsResource {
            let dataProvider = ArtistsDataProvider(artistsResource: artistsResource, reload: {
                [weak self] in
                guard let `self` = self else { return }
                self.tableView?.reloadData()
            })
            if let section1Populator = OFASectionPopulator(parentView: tableView, dataProvider: dataProvider, cellIdentifier: {
                _,_  in
                return "Cell1"
            }, cellConfigurator: {
                obj, cellView, indexPath in
                if let cell = cellView as? ArtistTableViewCell, let artist = obj as? Artist {
                    cell.configure(withArtist:artist)
                }
            }){
                section1Populator.objectOnCellSelected = {
                    [weak self]
                    (obj, cell, indexPath) -> Void in
                    guard let `self` = self else { return }
                    if let artist = obj as? Artist, let indexPath = indexPath {
                        for observer:ArtistSelectionObserver in self.selectionObservers.allObjects {
                            observer.selected(artist, on: indexPath)
                        }
                    }
                }
                self.populator = OFAViewPopulator(sectionPopulators: [section1Populator])
            }  else {
                throw DatasourceError.creationError("Could not create OFASectionPopulator")
            }
        }
    }
}
