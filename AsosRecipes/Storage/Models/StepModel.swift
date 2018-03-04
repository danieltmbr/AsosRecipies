//
//  StepModel.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 04..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import RealmSwift

final class StepModel: Object {
    /** Instruction of the step */
    @objc dynamic var instruction: String = ""
    /** Timer for the step in minutes */
    @objc dynamic var timer: Int = 0
}
