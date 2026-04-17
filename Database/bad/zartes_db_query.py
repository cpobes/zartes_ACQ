"""
zartes_db_query.py
Helper script called by MATLAB to query ZarTESDB (PostgreSQL).

Usage (from MATLAB via system() or called with arguments):
    python3 zartes_db_query.py <device_name> [<device_name2> ...]

Returns a JSON array to stdout, one object per device:
  [{"device_name":"4Z2_62_14","size":"40x80","nickname":"XIFU-8",
    "has_membrane":1,"has_absorber":1,"found":true}, ...]

If a device is not found, "found" is false and other fields are null.
"""

import sys
import json
import psycopg2

# ── Connection settings ────────────────────────────────────────────────────────
DB_CONFIG = {
    "host":     "155.210.93.184",   # or your server IP/hostname
    "port":     5432,
    "dbname":   "zartesdb",
    "user":     "invitado",
    "password": "invitado",   # adjust to your password
}

QUERY = """
SELECT
    vd.device_name,
    vd.chip_nickname                                       AS nickname,
    CAST(vd.tes_width_um  AS INTEGER) || 'x' ||
    CAST(vd.tes_length_um AS INTEGER)                      AS size,
    vd.tes_width_um,
    vd.tes_length_um,
    vd.abs_width_um,
    vd.stem_type,
    vd.has_membrane,
    vd.has_absorber,
    vd.wafer_name,
    vd.series
FROM v_device vd
WHERE vd.device_name = %s
LIMIT 1;
"""


def query_device(cur, device_name: str) -> dict:
    cur.execute(QUERY, (device_name,))
    row = cur.fetchone()
    if row is None:
        return {"device_name": device_name, "found": False,
                "size": None, "nickname": None,
                "has_membrane": None, "has_absorber": None}
    cols = [desc[0] for desc in cur.description]
    d = dict(zip(cols, row))
    d["found"] = True
    return d


def main():
    devices = sys.argv[1:]
    if not devices:
        print(json.dumps({"error": "No device names provided"}))
        sys.exit(1)

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur  = conn.cursor()
        results = [query_device(cur, dev) for dev in devices]
        conn.close()
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)

    print(json.dumps(results, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
