// export-sqlite-to-csv.js
// Run from migration/ folder with: node export-sqlite-to-csv.js

const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

const DB_FILE = process.env.SQLITE_FILE || path.join(process.cwd(), 'exhibition.db');
const OUT_DIR = path.join(process.cwd(), 'csv_export');

if (!fs.existsSync(DB_FILE)) {
  console.error('SQLite DB not found at', DB_FILE);
  process.exit(1);
}
if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR, { recursive: true });

const db = new sqlite3.Database(DB_FILE, sqlite3.OPEN_READONLY, (err) => {
  if (err) {
    console.error('Failed to open DB:', err.message);
    process.exit(2);
  }
});

function quoteCsv(value) {
  if (value === null || value === undefined) return '';
  // convert buffers to string
  if (Buffer.isBuffer(value)) value = value.toString('utf8');
  // stringify
  let s = String(value);
  // escape double quotes
  s = s.replace(/"/g, '""');
  return `"${s}"`;
}

db.serialize(() => {
  db.all("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name;", (err, rows) => {
    if (err) {
      console.error('Error listing tables:', err.message);
      db.close();
      process.exit(3);
    }
    const tables = rows.map(r => r.name);
    if (!tables.length) {
      console.log('No user tables found.');
      db.close();
      return;
    }
    console.log('Tables to export:', tables.join(', '));

    (async function exportAll() {
      for (const t of tables) {
        await new Promise((resolve) => {
          const outPath = path.join(OUT_DIR, `${t}.csv`);
          const outStream = fs.createWriteStream(outPath, { encoding: 'utf8' });
          // Get columns
          db.all(`PRAGMA table_info(${t});`, (err2, cols) => {
            if (err2) {
              console.error(`Failed to get columns for ${t}:`, err2.message);
              outStream.end(() => resolve());
              return;
            }
            const colNames = cols.map(c => c.name);
            // write header
            outStream.write(colNames.map(c => `"${c.replace(/"/g,'""')}"`).join(',') + '\n');

            // stream rows
            db.each(`SELECT * FROM ${t};`, (err3, row) => {
              if (err3) {
                console.error(`Error reading rows from ${t}:`, err3.message);
                return;
              }
              const vals = colNames.map(c => {
                const v = row[c];
                return quoteCsv(v);
              });
              outStream.write(vals.join(',') + '\n');
            }, (errCount, n) => {
              if (errCount) {
                console.error(`Finished ${t} with error:`, errCount.message);
              } else {
                console.log(`Exported ${t} (${n} rows) -> ${outPath}`);
              }
              outStream.end(() => resolve());
            });
          });
        });
      } // for
      db.close();
      console.log('All exports done. Files in:', OUT_DIR);
    })();
  });
});
