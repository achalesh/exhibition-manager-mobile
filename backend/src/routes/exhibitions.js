import express from 'express';
import { db } from '../db.js';
const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const list = await db('exhibitions').select('*').orderBy('start_date', 'desc');
    res.json(list);
  } catch (err) { console.error(err); res.status(500).json({ error: 'db error' }); }
});

export default router;
