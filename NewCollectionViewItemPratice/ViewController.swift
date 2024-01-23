//
//  ViewController.swift
//  NewCollectionViewItemPratice
//
//  Created by LinZheHao on 2023/10/3.
//

import UIKit


enum OutlineItem: Hashable {
    case parent(Parent)
    case child(Child)
}
struct Child : Hashable{
    let item: String
}

struct Parent: Hashable {
    let item: String
    let childItems: [Child]
}

class ViewController: UIViewController {
    
//    let collection: UICollectionView =  {
//        let frame = UIScreen.main.bounds
//        let collection = UICollectionView(frame: frame, collectionViewLayout: .init())
//        collection.isScrollEnabled = true
//        collection.bounces = true
//        collection.backgroundColor = .blue
//        collection.contentInsetAdjustmentBehavior = .never
//        collection.alwaysBounceVertical = true
//        return collection
//    }()
    
    var collectionView : UICollectionView!
    private lazy var dataSource = makeDataSource()

    // 假定資料
    let hirerachicalData = [
            
        Parent(item: "First", childItems: Array(0...4).map { Child(item: String($0)) }),
        Parent(item: "Second", childItems: Array(5...10).map { Child(item: String($0)) }),
        Parent(item: "Third", childItems: Array(11...13).map { Child(item: String($0)) }),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        // collectionView 初始化
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        
        // 程式碼設置 autolayout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // 設置資料進去後呈現的邏輯
        collectionView.dataSource = dataSource

        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<OutlineItem>()
        
        // 設置要呈現的資料內容
        for data in hirerachicalData{
            
            let header = OutlineItem.parent(data)
            sectionSnapshot.append([header])
            sectionSnapshot.append(data.childItems.map { OutlineItem.child($0) }, to: header)

            // 一開始就展開 section
            sectionSnapshot.expand([header])
        }
        
        // snapshot: 表格顯示的內容。 animatingDifferences: 是否有動畫
        dataSource.apply(sectionSnapshot, to: "Root", animatingDifferences: false, completion: nil)
    }
    
    // 產生 UITableViewDiffableDataSource & 設定 cell 內容
    func makeDataSource() -> UICollectionViewDiffableDataSource<String, OutlineItem> {
        // 一般 deque 機制
//        dataSource = UITableViewDiffableDataSource<Section, Movie>(tableView: tableView) { tableView, indexPath, itemIdentifier in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
//            cell.textLabel?.text = itemIdentifier.name
//            cell.imageView?.image = UIImage(named: itemIdentifier.actor)
//            return cell
//        }
//        tableView.dataSource = dataSource
        
        // 用程式碼建立 header
        let parentRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Parent> { cell, indexPath, item in
            
            var content = cell.defaultContentConfiguration()
            content.text = item.item
            cell.contentConfiguration = content
            
            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options:headerDisclosureOption)]
            
        }
        
        // 用程式碼建立 cell
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Child> { cell, indexPath, item in
            
            var content = cell.defaultContentConfiguration()
            content.text = item.item
            cell.indentationLevel = 2
            cell.contentConfiguration = content
        }
        
        return UICollectionViewDiffableDataSource<String, OutlineItem>(
                    collectionView: collectionView,
                    cellProvider: { collectionView, indexPath, item in
    
                        
                    switch item{
                        case .parent(let parentItem):
                            
                            let cell = collectionView.dequeueConfiguredReusableCell(
                                using: parentRegistration,
                                for: indexPath,
                                item: parentItem)
    
                            return cell

                        case .child(let childItem):
    
                            let cell = collectionView.dequeueConfiguredReusableCell(
                                using: cellRegistration,
                                for: indexPath,
                                item: childItem)
    
                            return cell
                    }
        })
    }
}
/// DataSource
//private func makeDataSource() -> DataSource {
//    let dataSource = DataSource(collectionView: listView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item) -> UICollectionViewCell? in
//        guard let self = self else { return nil }
//        let section = self.sections[indexPath.section]
//        let id = item.reuseId(section.style)
//        let reCell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)
//        switch item {
//        case .loading:
//            break
//
//        case let .promo(item):
//            let cell = reCell as! Ad08PCell
//            cell.setup(section.style, pos: indexPath, item: item)
//
//        case let .style(item):
//            let cell = reCell as! AdListCell
//            if let s07Cell = cell as? Ad07Cell {
//                s07Cell.textAlign = section.textAlign
//            }
//            cell.setup(section.style, pos: indexPath, item: item)
//            cell.delegate = self
//        }
//        return reCell
//    }
//    return dataSource
//}
