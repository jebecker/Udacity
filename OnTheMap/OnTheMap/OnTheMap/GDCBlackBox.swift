//
//  GDCBlackBox.swift
//  OnTheMap
//
//  Created by Jayme Becker on 10/15/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
