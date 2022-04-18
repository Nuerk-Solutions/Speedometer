//
//  KeyValueRow.swift
//  Speedometer
//
//  Created by Thomas on 18.04.22.
//

import SwiftUI

struct KeyValueRow: View {
    
    @State var key: String?
    var value: String?
    
    var body: some View {
        HStack {
            Text(key ?? "-1")
            Spacer()
            Text(value ?? "-1")
        }
    }
}

struct KeyValueRow_Previews: PreviewProvider {
    static var previews: some View {
        KeyValueRow()
    }
}
