//
//  Chip.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/19/21.
//

import SwiftUI

struct SmallChip: View {
    let color: Color
    let label: String
    let onPressed: () -> ()
    
    var body: some View {
        Button(action: onPressed, label: {
            Text(label).font(.system(size: 10)).foregroundColor(.white).padding(.horizontal, 6).padding(.vertical, 3).background(color).cornerRadius(12.0)
        })
    }
}

struct Chip: View {
    let color: Color
    let label: String
    let onPressed: () -> ()
    
    var body: some View {
        Button(action: onPressed, label: {
            Text(label).font(.system(size: 14)).foregroundColor(.white).padding(.horizontal, 6).padding(.vertical, 3).background(color).cornerRadius(12.0)
        })
    }
}

struct Chip_Previews: PreviewProvider {
    static var previews: some View {
        Chip(color: Color.blue, label: "Bug", onPressed: {})
    }
}
