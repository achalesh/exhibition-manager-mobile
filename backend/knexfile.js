import dotenv from 'dotenv';
dotenv.config();


export default {
development: {
client: 'mysql2',
connection: {
host: process.env.DB_HOST || '127.0.0.1',
user: process.env.DB_USER || 'appuser',
password: process.env.DB_PASSWORD || 'apppass',
database: process.env.DB_NAME || 'exhibitiondb',
port: Number(process.env.DB_PORT) || 3306
}
}
};