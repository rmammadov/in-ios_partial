//
//  ScreenTypeGViewModel.swift
//  in-ios
//
//  Created by Piotr Soboń on 22/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class ScreenTypeGViewModel: BaseViewModel {
    
    weak var delegate: ScreenTypeCDelegate?
    var inputScreen: InputScreen!
    private var items = [ButtonInputScreen]()
    private var selectedIndex: IndexPath?
    
}
