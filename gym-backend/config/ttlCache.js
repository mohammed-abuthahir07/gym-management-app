class TtlCache {
    constructor() {
        this._store = new Map();
    }

    get(key) {
        const hit = this._store.get(key);
        if (!hit) return null;
        if (Date.now() > hit.expiresAt) {
            this._store.delete(key);
            return null;
        }
        return hit.value;
    }

    set(key, value, ttlMs = 30000) {
        this._store.set(key, {
            value,
            expiresAt: Date.now() + ttlMs,
        });
        return value;
    }

    clear() {
        this._store.clear();
    }
}

module.exports = new TtlCache();
