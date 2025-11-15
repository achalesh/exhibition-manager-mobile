// inspect-sqlite.js — run from migration/ folder
const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

const file = process.env.SQLITE_FILE || path.resolve(process.cwd(), 'exhibition.db');

if (!fs.existsSync(file)) {
  console.error('File not found:', file);
  process.exit(2);
}

// print first 64 bytes (hex + ascii)
const buf = fs.readFileSync(file, { length: 64 });
const hex = Array.from(buf).map(b => b.toString(16).padStart(2, '0')).join(' ');
const ascii = buf.toString('ascii').replace(/\0/g, '\\0');
console.log('HEADER (hex):', hex);
console.log('HEADER (ascii):', ascii);

const db = new sqlite3.Database(file, sqlite3.OPEN_READONLY, (err) => {
  if (err) {
    console.error('Failed to open SQLite DB:', err.message);
    process.exit(3);
  }
});

db.serialize(() => {
  db.all("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;", (err, rows) => {
    if (err) {
      console.error('Error reading sqlite_master:', err.message);
    } else {
      console.log('\\nTABLES:');
      if (!rows.length) {
        console.log('(no tables found)');
      } else {
        rows.forEach(r => console.log('-', r.name));
      }
    }

    db.all("SELECT name, sql FROM sqlite_master WHERE type='table' ORDER BY name;", (err2, rows2) => {
      if (err2) {
        console.error('Error reading schemas:', err2.message);
      } else {
        console.log('\\nSCHEMAS:');
        if (!rows2.length) {
          console.log('(no schema rows)');
        } else {
          rows2.forEach(r => {
            console.log('\\n--', r.name);
            console.log(r.sql);
          });
        }
      }
      db.close();
    });
  });
});
