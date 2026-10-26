# Astrodiagramma

Astrodiagramma is a small Lua project for astronomy calculations and working with sky coordinates. It also includes scripts to download Gaia DR3 source data and import a CSV result into SQLite.

## Requirements

- Lua
- `curl` for the Gaia downloader
- `sqlite3` command-line program for CSV import

No Lua packages are needed for the download and import scripts. Run commands from the project root so their default input and output paths resolve as shown.

## Download Gaia DR3 data

The downloader selects `source_id`, right ascension (`ra`), declination (`dec`), and Gaia G-band magnitude (`phot_g_mean_mag`) from `gaiadr3.gaia_source`, keeping sources at or below the supplied magnitude limit.

```sh
lua astrodiagramma/download_gaia.lua 14.0
```

This saves a CSV such as `gaia_dr3_gmag_14_0.csv`. Pass a second argument to choose the output path:

```sh
lua astrodiagramma/download_gaia.lua 14.0 bright_sources.csv
```

The script submits an asynchronous query to the ESA Gaia Archive, polls until the job completes, and downloads the result. The archive may cap the number of returned rows.

## Convert a CSV to SQLite

```sh
lua astrodiagramma/csv_to_sqlite.lua bright_sources.csv bright_sources.db
```

The output database contains a `gaia_sources` table with these columns:

| Column | SQLite type | Description |
| --- | --- | --- |
| `source_id` | `INTEGER` | Gaia source identifier; primary key |
| `ra` | `REAL` | Right ascension in degrees |
| `dec` | `REAL` | Declination in degrees |
| `phot_g_mean_mag` | `REAL` | Gaia G-band mean magnitude |

An index is created on `phot_g_mean_mag`. If the output database already exists, the script replaces its `gaia_sources` rows with the CSV contents. The input CSV path must not contain spaces because of the SQLite CLI import command.

For example, to convert the CSV created by the downloader:

```sh
lua astrodiagramma/download_gaia.lua 14.0 bright_sources.csv
lua astrodiagramma/csv_to_sqlite.lua bright_sources.csv bright_sources.db
```

Query the resulting database with SQLite:

```sh
sqlite3 bright_sources.db \
  'SELECT source_id, ra, dec, phot_g_mean_mag FROM gaia_sources ORDER BY phot_g_mean_mag LIMIT 10;'
```

## Lua modules

- `astrodiagramma/astrocoord.lua` — coordinate object and angular coordinate conversion.
- `astrodiagramma/units.lua` — angle and time unit conversion helpers.
- `astrodiagramma/calculations.lua` — angle, interpolation, and related calculation helpers.
- `astrodiagramma/constants.lua` — physical and astronomical constants.
- `astrodiagramma/io.lua` — table formatting helper.

The `notes/` directory contains learning examples and chapter notes.

## Gaia data acknowledgment

If you use Gaia DR3 data in research, acknowledge it as follows:

> This work has made use of data from the European Space Agency (ESA) mission Gaia (https://www.cosmos.esa.int/gaia), processed by the Gaia Data Processing and Analysis Consortium (DPAC, https://www.cosmos.esa.int/web/gaia/dpac/consortium). Funding for the DPAC has been provided by national institutions, in particular the institutions participating in the Gaia Multilateral Agreement.

Research using Gaia DR3 should also cite the Gaia mission paper and the Gaia DR3 release paper. See the [official Gaia DR3 credit and citation instructions](https://gea.esac.esa.int/archive/documentation/GDR3/Miscellaneous/sec_credit_and_citation_instructions/) for the recommended citations and additional references relevant to your work.
