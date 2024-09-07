import Settings

import WinSDK

struct WindowsRegistryConfigurationPersistenceService: ConfigurationPersistenceService {
    private static let subKey: [UInt16] = "SOFTWARE\\Fellmonger".wide

    func get(key: String) -> String? {
        var value = key.wide
        var buffer: [WCHAR] = [WCHAR](repeating: 0, count: 64)
        var status: LSTATUS = doGet(value: &value, buffer: &buffer)

        while status == ERROR_MORE_DATA {
            buffer = [WCHAR](repeating: 0, count: buffer.count * 2)
            status = doGet(value: &value, buffer: &buffer)
        }

        if status == ERROR_FILE_NOT_FOUND {
            return nil
        }

        guard status == ERROR_SUCCESS else {
            // TODO: Log error
            return nil
        }

        return String(decodingCString: buffer, as: UTF16.self)
    }

    private func doGet(value: inout [UInt16], buffer: inout [WCHAR]) -> LSTATUS {
        var subKey = Self.subKey
        var cbData: DWORD = DWORD(buffer.count * MemoryLayout<WCHAR>.size)

        return RegGetValueW(
            HKEY_CURRENT_USER,
            &subKey,
            value,
            DWORD(RRF_RT_REG_SZ | RRF_ZEROONFAILURE),
            nil,
            &buffer,
            &cbData
        )
    }

    func set(key: String, value: String) {
        var subKey = Self.subKey
        var registryValue: [UInt16] = key.wide
        var buffer: [UInt16] = value.wide
        let cbData: DWORD = DWORD(buffer.count * MemoryLayout<WCHAR>.size)

        RegSetKeyValueW(
            HKEY_CURRENT_USER, 
            &subKey, 
            &registryValue, 
            REG_SZ, 
            &buffer, 
            cbData
        )
    }
}

/// https://github.com/compnerd/swift-win32/blob/45a9e4e83cef6ffeef0509c34452d648e88d8eb6/Sources/SwiftWin32/Support/Array%2BExtensions.swift
private extension String {
    var wide: [UInt16] {
        return [UInt16](from: self)
    }
}

private extension Array where Element == UInt16 {
    init(from string: String) {
        self = string.withCString(encodedAs: UTF16.self) { buffer in
            [UInt16](unsafeUninitializedCapacity: string.utf16.count + 1) {
                wcscpy_s($0.baseAddress, $0.count, buffer)
                $1 = $0.count
            }
        }
    }
}
