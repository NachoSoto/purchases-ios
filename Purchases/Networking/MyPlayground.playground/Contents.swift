import UIKit

let data = "7b227265 71756573 745f6461 7465223a 22323032 322d3032 2d313654 31393a30 353a3135 5a222c22 73756273 63726962 6572223a 7b226e6f 6e5f7375 62736372 69707469 6f6e7322 3a7b7d2c 22666972 73745f73 65656e22 3a223230 32322d30 322d3136 5431393a 30353a31 345a222c 226f7269 67696e61 6c5f6170 706c6963 6174696f 6e5f7665 7273696f 6e223a6e 756c6c2c 226f7468 65725f70 75726368 61736573 223a7b7d 2c226d61 6e616765 6d656e74 5f75726c 223a6e75 6c6c2c22 73756273 63726970 74696f6e 73223a7b 7d2c2265 6e746974 6c656d65 6e747322 3a7b7d2c 226f7269 67696e61 6c5f7075 72636861 73655f64 61746522 3a6e756c 6c2c226f 72696769 6e616c5f 6170705f 75736572 5f696422 3a222452 43416e6f 6e796d6f 75734944 3a326130 32633762 66646439 37343535 33386638 32373138 32386435 63366661 63222c22 6c617374 5f736565 6e223a22 32303232 2d30322d 31365431 393a3035 3a31345a 227d2c22 72657175 6573745f 64617465 5f6d7322 3a313634 35303338 33313530 32382c22 73636865 6d615f76 65727369 6f6e223a 2232227d"
    .replacingOccurrences(of: " ", with: "")

//let d = Data(
let d = convertHexToBytes(data)

print(try! JSONSerialization.jsonObject(with: d!, options: []))
//String(data: d!, encoding: .utf16)

func convertHexToBytes(_ str: String) -> Data? {
    let values = str.compactMap { $0.hexDigitValue } // map char to value of 0-15 or nil
    if values.count == str.count && values.count % 2 == 0 {
        var data = Data()
        for x in stride(from: 0, to: values.count, by: 2) {
            let byte = (values[x] << 4) + values[x+1] // concat high and low bits
            data.append(UInt8(byte))
        }
        return data
    }
    return nil
}
