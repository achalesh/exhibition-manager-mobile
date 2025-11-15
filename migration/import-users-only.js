// import-users-only.js
// Usage: node import-users-only.js
// Requires: npm install mysql2 csv-parse
// Imports csv_export/users.csv into MySQL (127.0.0.1:3307) without truncating other tables.

const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const { parse } = require('csv-parse/sync');

const CSV = path.join(process.cwd(), 'csv_export', 'users.csv');

const DB = {
  host: '127.0.0.1',
  port: 3307,
  user: 'root',
  password: 'rootpassword', // change if your password differs
  database: 'exhibitiondb',
};

if (!fs.existsSync(CSV)) {
  console.error('users.csv not found at', CSV);
  process.exit(1);
}

function readCsv() {
  const txt = fs.readFileSync(CSV, 'utf8');
  return parse(txt, { columns: true, skip_empty_lines: true, trim: true });
}

// Insert rows in batches (200)
const BATCH = 200;

async function main() {
  const rows = readCsv();
  console.log('Rows to import:', rows.length);
  if (!rows.length) return;

  const conn = await mysql.createConnection(DB);
  try {
    console.log('Connected to MySQL at', `${DB.host}:${DB.port}/${DB.database}`);

    // We'll insert rows without truncating the table (non-destructive).
    // Use INSERT IGNORE in case IDs already exist — change to REPLACE if you prefer replace.
    const cols = Object.keys(rows[0]);
    const colEsc = cols.map(c => `\`${c}\``).join(',');
    for (let i = 0; i < rows.length; i += BATCH) {
      const chunk = rows.slice(i, i + BATCH);
      const placeholders = chunk.map(_ => '(' + cols.map(_ => '?').join(',') + ')').join(',');
      const values = [];
      chunk.forEach(r => {
        // keep empty strings as '' for text columns; do NOT convert to null to avoid NOT NULL errors
        cols.forEach(c => {
          let v = r[c];
          if (v === undefined) v = null;
          values.push(v === '' ? '' : v);
        });
      });
      const sql = `INSERT IGNORE INTO \`users\` (${colEsc}) VALUES ${placeholders};`;
      await conn.query(sql, values);
      console.log(`Inserted rows ${i}..${i + chunk.length - 1}`);
    }

    console.log('Users import finished.');
  } catch (err) {
    console.error('Error importing users:', err.message);
    process.exit(2);
  } finally {
    await conn.end();
  }
}

main().catch(e => { console.error(e); process.exit(1); });
