//
//  ContentView.swift
//  Demo
//
//  Created by wanglei on 2024/5/6.
//

import SwiftUI
import Serde
import Aptos

struct ContentView: View {
    var test = 0x456
    @State var data = "Hello, Aptos!"
    @State var isSer = true
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(data)
            
            Button(action: {
                Aptos.sayHello()
                do {
                    if isSer {
                        let bcsSer = BcsSerializer()
                        try bcsSer.serialize_str(value: data)
                        data =  bcsSer.get_bytes().toHexString()
                    } else {
                        let bcsDer = BcsDeserializer(input: data.toBytes() )
                        data = try bcsDer.deserialize_str()
                    }
                } catch {
                    print(error)
                }
                isSer.toggle()
            }, label: {
                Text(isSer ? "serilize" : "deserilize")
            }).padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

// [UInt8] to hex
extension Array where Element == UInt8 {
    func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}

// HexString to [UInt8]
extension String {
    func toBytes() -> [UInt8] {
        var data = Data()
        for i in stride(from: 0, to: count, by: 2) {
            let start = index(startIndex, offsetBy: i)
            let end = index(start, offsetBy: 2, limitedBy: endIndex) ?? endIndex
            if let byte = UInt8(self[start..<end], radix: 16) {
                data.append(byte)
            }
        }
        return [UInt8](data)
    }
}
