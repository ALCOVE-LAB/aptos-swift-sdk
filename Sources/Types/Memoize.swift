import Foundation

// Define a type to hold the cached value and timestamp
 private struct CacheEntry<T> {
    let value: T
    let timestamp: TimeInterval
}

// Global cache dictionary shared across all functions
private var cache = [String: Any]()


public func memoizeAsync<ReturnType, Args>(
    _ closure: @escaping (Args) async throws -> ReturnType,
    key: String,
    ttlMs: TimeInterval? = nil
) -> (Args) async throws -> ReturnType {
    return { (args) in
        
        // Check if the cached result exists and is within TTL
        if let cacheEntry = cache[key] as? CacheEntry<ReturnType> {
            if let ttlMs = ttlMs, Date().timeIntervalSince1970 - cacheEntry.timestamp <= ttlMs / 1000 {
                return cacheEntry.value
            }
        }
        
        // If not cached or TTL expired, compute the result
        let result = try await closure(args)
        
        // Cache the result with a timestamp
        cache[key] = CacheEntry(value: result, timestamp: Date().timeIntervalSince1970)
        
        return result
    }
}

public func memoizeSync<ReturnType, Args>(
    _ closure: @escaping (Args) throws -> ReturnType,
    key: String,
    ttlMs: TimeInterval? = nil
) -> (Args) throws -> ReturnType {
    return { (args) in
        
        // Check if the cached result exists and is within TTL
        if let cacheEntry = cache[key] as? CacheEntry<ReturnType> {
            if let ttlMs = ttlMs, Date().timeIntervalSince1970 - cacheEntry.timestamp <= ttlMs / 1000 {
                return cacheEntry.value
            }
        }
        // If not cached or TTL expired, compute the result
        let result = try closure(args)
        
        // Cache the result with a timestamp
        cache[key] = CacheEntry(value: result, timestamp: Date().timeIntervalSince1970)
        
        return result
    }
}
