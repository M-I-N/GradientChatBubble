//
//  ViewController.swift
//  GradientChatBubble
//
//  Created by Mufakkharul Islam Nayem on 26/6/22.
//

import UIKit
import SnapKit


class CustomCell : UICollectionViewCell {
                
    var bubbleView:UIView = UIView()
    var frontView:UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        frontView.backgroundColor = .systemBackground
        contentView.addSubview(frontView)
        
        frontView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bubbleView.backgroundColor = .clear
        bubbleView.clipsToBounds = true
        bubbleView.layer.cornerRadius = 20
        contentView.addSubview(bubbleView)
        
        bubbleView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMask(with hole: CGRect, in view: UIView, and cornerRadius:CGFloat) {
        let path = UIBezierPath(rect: view.bounds)
        let pathWithRadius = UIBezierPath(roundedRect: hole, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        path.append(pathWithRadius)

        // Create a shape layer and cut out the intersection
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillRule = CAShapeLayerFillRule.evenOdd
        
        // Add the mask to the view
        view.layer.mask = mask
    }
}


class ViewController: UIViewController {

    
    var collectionView : UICollectionView!
    var data:UICollectionViewDiffableDataSource<Int, UUID>!
    
    var maskLayer: CAShapeLayer!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var snap = data.snapshot()
        snap.appendSections([0])
        snap.appendItems([UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID()])
        data.apply(snap, animatingDifferences: true, completion: nil)
    }

    func setupUI() {
        
        let gradientBackgroundColors = [UIColor.blue.cgColor, UIColor.systemPink.cgColor]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientBackgroundColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.locations = [0.0 , 1.0]
        gradientLayer.frame = view.frame
        
        let backgroundView = UIView(frame: view.frame)
        backgroundView.layer.addSublayer(gradientLayer)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: getLayout())
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.backgroundView = backgroundView
        collectionView.contentInsetAdjustmentBehavior = .never
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setupData() {
        data = UICollectionViewDiffableDataSource<Int, UUID>.init(collectionView: collectionView, cellProvider: { (collectionView, indexPath, uuid) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCell else {return nil}
            cell.backgroundColor = .systemBackground
            return cell
        })
    }
    
    func getLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let header = NSCollectionLayoutBoundarySupplementaryItem.init(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        header.pinToVisibleBounds = true
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100)), subitems: [item])
        let section = NSCollectionLayoutSection.init(group: group)
//        section.boundarySupplementaryItems = [header]
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}


extension UIViewController : UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let myCell = cell as? CustomCell {
            myCell.backgroundColor = .clear
            myCell.layoutIfNeeded()
            let hole = myCell.bubbleView.frame.integral
            myCell.setMask(with: hole, in: myCell.frontView, and: 12)
        }
    }
}
