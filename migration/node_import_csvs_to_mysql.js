// node_import_csvs_to_mysql.js
// Usage: node node_import_csvs_to_mysql.js
// Requires: npm install mysql2 csv-parse dotenv
//
// IMPORTANT: Create a .env file in this directory for DB configuration.

const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const { parse } = require('csv-parse/sync');
require('dotenv').config(); // Load .env file

const CSV_DIR = path.join(process.cwd(), 'csv_export');

const DB = {
  host: process.env.DB_HOST || '127.0.0.1',
  port: process.env.DB_PORT || 3307,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE || 'exhibitiondb',
};

const BATCH_SIZE = 200;

function readCsvFull(filepath) {
  const txt = fs.readFileSync(filepath, 'utf8');
  // parse CSV with header as columns
  const records = parse(txt, { columns: true, skip_empty_lines: true, trim: true });
  return records;
}

async function importFile(conn, filepath) {
  const file = path.basename(filepath);
  const table = path.basename(filepath, '.csv');

  const records = readCsvFull(filepath);
  if (!records.length) {
    console.log(`Skipping ${table} (0 rows)`);
    return { table, imported: 0 };
  }
  const cols = Object.keys(records[0]);

  console.log(`Importing ${records.length} rows into ${table} (${cols.length} columns)`);

  // Prepare insert template
  const colEsc = cols.map(c => `\`${c}\``).join(',');
  const placeholders = '(' + cols.map(_ => '?').join(',') + ')';

  for (let i = 0; i < records.length; i += BATCH_SIZE) {
    const chunk = records.slice(i, i + BATCH_SIZE);
    const values = [];
    const placeGroups = chunk.map(r => {
      cols.forEach(c => {
        const v = r[c] === '' ? null : r[c];
        values.push(v);
      });
      return placeholders;
    }).join(',');

    const sql = `INSERT INTO \`${table}\` (${colEsc}) VALUES ${placeGroups}`;
    try {
      await conn.query(sql, values);
    } catch (err) {
      // If insert fails due to strict types or unknown columns, show helpful info
      console.error(`Error inserting into ${table} (batch starting at ${i}):`, err.message);
      throw err;
    }
  }

  return { table, imported: records.length };
}

async function main() {
  if (!fs.existsSync(CSV_DIR)) {
    console.error('CSV directory not found:', CSV_DIR);
    process.exit(1);
  }
  const files = fs.readdirSync(CSV_DIR).filter(f => f.endsWith('.csv') && f !== 'sqlite_sequence.csv');

  const conn = await mysql.createConnection(DB);
  try {
    console.log('Connected to MySQL at', `${DB.host}:${DB.port}/${DB.database}`);

    // Disable FK checks and truncate targets for a clean import
    console.log('Disabling FOREIGN_KEY_CHECKS and truncating tables (clean import)');
    await conn.query('SET FOREIGN_KEY_CHECKS = 0;');

    // Truncate in safe order: try to truncate all (MySQL will error if FK constraints exist; FK checks are off so OK)
    for (const f of files) {
      const t = path.basename(f, '.csv');
      try {
        await conn.query(`TRUNCATE TABLE \`${t}\`;`);
        console.log(`Truncated ${t}`);
      } catch (e) {
        console.warn(`Warning truncating ${t}: ${e.message}`);
      }
    }

    // Import each file
    for (const f of files) {
      const filepath = path.join(CSV_DIR, f);
      try {
        const res = await importFile(conn, filepath);
        console.log(`Imported ${res.imported} rows into ${res.table}`);
      } catch (err) {
        console.error('Aborting due to error. Table:', f, err.message);
        throw err;
      }
    }

    await conn.query('SET FOREIGN_KEY_CHECKS = 1;');
    console.log('Re-enabled FOREIGN_KEY_CHECKS. Import finished.');
  } finally {
    await conn.end();
  }
}

main().catch(err => {
  console.error('Fatal error:', err.message);
  process.exit(1);
});
