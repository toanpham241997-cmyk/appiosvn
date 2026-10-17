import Foundation
import UIKit
import Darwin

struct DeviceSnapshot {
    let vendorID: String
    let deviceName: String
    let hardwareModel: String
    let systemVersion: String
    let coreCount: Int
    let totalRAM: UInt64
    let appMemory: UInt64?
    let battery: Int?
    let storageTotal: UInt64
    let storageFree: UInt64
    let thermal: String

    static func readableBytes(_ bytes: UInt64) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(clamping: bytes), countStyle: .memory)
    }
}

@MainActor final class DeviceMonitor: ObservableObject {
    @Published private(set) var snapshot: DeviceSnapshot

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        snapshot = Self.read()
    }

    func refresh() { snapshot = Self.read() }

    private static func read() -> DeviceSnapshot {
        let device = UIDevice.current
        let proc = ProcessInfo.processInfo
        let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        let total = (attrs?[.systemSize] as? NSNumber)?.uint64Value ?? 0
        let free = (attrs?[.systemFreeSize] as? NSNumber)?.uint64Value ?? 0
        let batteryValue = device.batteryLevel
        let battery = batteryValue >= 0 ? Int((batteryValue * 100).rounded()) : nil
        let thermal: String
        switch proc.thermalState {
        case .nominal: thermal = "Bình thường"
        case .fair: thermal = "Ấm"
        case .serious: thermal = "Cao"
        case .critical: thermal = "Rất cao"
        @unknown default: thermal = "Không xác định"
        }
        return DeviceSnapshot(
            vendorID: device.identifierForVendor?.uuidString ?? "Chưa khả dụng",
            deviceName: device.name,
            hardwareModel: hardwareIdentifier(),
            systemVersion: "\(device.systemName) \(device.systemVersion)",
            coreCount: proc.activeProcessorCount,
            totalRAM: proc.physicalMemory,
            appMemory: memoryFootprint(),
            battery: battery, storageTotal: total, storageFree: free, thermal: thermal
        )
    }

    private static func hardwareIdentifier() -> String {
        var info = utsname()
        uname(&info)
        let machineSize = MemoryLayout.size(ofValue: info.machine)
        return withUnsafePointer(to: &info.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: machineSize) {
                String(cString: $0)
            }
        }
    }

    // Only the current Aujunpeak process footprint; not system-wide used RAM.
    private static func memoryFootprint() -> UInt64? {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let code: kern_return_t = withUnsafeMutablePointer(to: &info) { p in
            p.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPointer in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPointer, &count)
            }
        }
        return code == KERN_SUCCESS ? info.phys_footprint : nil
    }
}
