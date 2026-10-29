# Astrodiagramma

Astrodiagramma is a Lua astronomy project with coordinate and unit calculations, an interactive command-line prototype, and utilities for downloading Gaia DR3 data and importing it into SQLite.

## Requirements

- Lua 5.5 (the current development setup)
- LuaRocks
- `curl` and `sqlite3` command-line tools for the Gaia data utilities
- The Lua modules `dkjson`, `luasocket`, and `lsqlite3`

Install the Lua modules with:

```sh
luarocks install dkjson
luarocks install luasocket
luarocks install lsqlite3
```

On Apple Silicon Macs using Homebrew SQLite, build `lsqlite3` against Homebrew's library if it loads with a missing SQLite symbol:

```sh
luarocks install lsqlite3 SQLITE_DIR=/opt/homebrew/opt/sqlite
```

## Run the application

From the project root:

```sh
lua astrodiagramma/astrodiagramma.lua
```

The current application is an interactive prototype. It loads settings from `astrodiagramma/configs/`, prompts for initial user and location settings when `exists` is false, and accepts `q` to quit. Automatic location lookup uses LuaSocket and an IP geolocation service. Configuration and database paths are currently resolved relative to the project root.

## Gaia data utilities

Download Gaia DR3 source IDs, coordinates, and G-band magnitudes up to a magnitude limit:

```sh
lua astrodiagramma/utils/download_gaia.lua 14.0 bright_sources.csv
```

The script submits an asynchronous query to the ESA Gaia Archive, waits for completion, and writes a CSV. The archive may limit the number of returned rows.

Import the CSV into a SQLite database:

```sh
lua astrodiagramma/utils/csv_to_sqlite.lua bright_sources.csv bright_sources.db
```

The resulting database has a `gaia_sources` table with columns `source_id` (`INTEGER PRIMARY KEY`), `ra` (`REAL`), `dec` (`REAL`), and `phot_g_mean_mag` (`REAL`). It also creates an index on magnitude. Re-running the importer replaces the table rows with the CSV contents. The import utility requires an input CSV path without spaces.

For example, inspect the brightest rows with:

```sh
sqlite3 bright_sources.db \
  'SELECT source_id, ra, dec, phot_g_mean_mag FROM gaia_sources ORDER BY phot_g_mean_mag LIMIT 10;'
```

## Project layout

- `astrodiagramma/astrodiagramma.lua` — command-line application entry point.
- `astrodiagramma/units.lua` and `astrodiagramma/calculations.lua` — unit conversions and astronomy calculations.
- `astrodiagramma/ouranos.lua`, `astrodiagramma/somatouranos.lua`, and `astrodiagramma/zenith.lua` — sky, body, and zenith models.
- `astrodiagramma/gaiadb.lua` — SQLite database wrapper using `lsqlite3`.
- `astrodiagramma/cio.lua` — JSON and file I/O helpers using `dkjson`.
- `astrodiagramma/configs/` — application and user settings.
- `astrodiagramma/database/` — local Gaia database.
- `astrodiagramma/utils/` — Gaia download and CSV import scripts.
- `notes/` — learning examples and chapter notes.

## To do

- Create a FITS viewer that loads images quickly, switches files without reopening the application, and remembers sessions.

## Gaia data acknowledgment

If you use Gaia DR3 data in research, acknowledge it as follows:

> This work has made use of data from the European Space Agency (ESA) mission Gaia (https://www.cosmos.esa.int/gaia), processed by the Gaia Data Processing and Analysis Consortium (DPAC, https://www.cosmos.esa.int/web/gaia/dpac/consortium). Funding for the DPAC has been provided by national institutions, in particular the institutions participating in the Gaia Multilateral Agreement.

Research using Gaia DR3 should also cite the Gaia mission paper and the Gaia DR3 release paper. See the [official Gaia DR3 credit and citation instructions](https://gea.esac.esa.int/archive/documentation/GDR3/Miscellaneous/sec_credit_and_citation_instructions/) for recommended citations and additional references relevant to your work.
