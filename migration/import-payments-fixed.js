// import-payments-fixed.js
// Usage: node import-payments-fixed.js
// Requires: npm install mysql2 csv-parse
// It will TRUNCATE payments and import payments.csv, generating a TMP receipt_number when missing.

const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const { parse } = require('csv-parse/sync');

const CSV = path.join(process.cwd(), 'csv_export', 'payments.csv');

const DB = {
  host: '127.0.0.1',
  port: 3307,
  user: 'root',
  password: 'rootpassword', // change if needed
  database: 'exhibitiondb',
};

const BATCH = 200;

if (!fs.existsSync(CSV)) {
  console.error('payments.csv not found at', CSV);
  process.exit(1);
}

function readCsv() {
  const txt = fs.readFileSync(CSV, 'utf8');
  return parse(txt, { columns: true, skip_empty_lines: true, trim: true });
}

function ensureReceipt(record, idx) {
  if (!record.hasOwnProperty('receipt_number') || record['receipt_number'] === '' || record['receipt_number'] === null) {
    record['receipt_number'] = `TMP-${Date.now()}-${idx}`;
  }
}

async function run() {
  const rows = readCsv();
  if (!rows.length) {
    console.log('No payments rows to import.');
    return;
  }
  const conn = await mysql.createConnection(DB);
  try {
    console.log('Connected to', `${DB.host}:${DB.port}/${DB.database}`);
    await conn.query('SET FOREIGN_KEY_CHECKS = 0;');
    await conn.query('TRUNCATE TABLE `payments`;');
    console.log('Truncated payments');

    const cols = Object.keys(rows[0]);
    const colEsc = cols.map(c => `\`${c}\``).join(',');

    for (let i = 0; i < rows.length; i += BATCH) {
      const chunk = rows.slice(i, i + BATCH);
      const values = [];
      const placeholders = chunk.map((r, j) => {
        ensureReceipt(r, i + j);
        cols.forEach(c => {
          const v = r[c] === '' ? '' : r[c];
          values.push(v === undefined ? null : v);
        });
        return '(' + cols.map(_ => '?').join(',') + ')';
      }).join(',');
      const sql = `INSERT INTO \`payments\` (${colEsc}) VALUES ${placeholders}`;
      await conn.query(sql, values);
      console.log(`Inserted rows ${i}..${i + chunk.length - 1}`);
    }

    await conn.query('SET FOREIGN_KEY_CHECKS = 1;');
    console.log('Import finished.');
  } catch (err) {
    console.error('Error importing payments:', err.message);
    process.exit(2);
  } finally {
    await conn.end();
  }
}

run().catch(e => { console.error(e); process.exit(1); });
