//
//  ModelRendererCell.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 03..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import UIKit

// MARK: -

protocol ModelRendererCell {
    /** Data type that the cell can display */
    associatedtype CellViewModel
    /** Displays data from model */
    func render(model: CellViewModel)
}

// MARK: -

extension UITableView {

    func getCell<C, M>(of type: C.Type, for indexPath: IndexPath, with model: M) -> C
        where C: UITableViewCell & ExternalCell & ModelRendererCell, C.CellViewModel == M  {
            // Dequeue cell
            guard let cell: C = dequeueExternalCell(for: indexPath)
                else { fatalError("Plese setup & register cell of type: \(String(describing: C.self))") }
            // Setup cell with model
            cell.render(model: model)
            return cell
    }
}
