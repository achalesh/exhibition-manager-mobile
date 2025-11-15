CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'attendee',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE organizations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  timezone VARCHAR(64) DEFAULT 'UTC',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE exhibitions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  org_id INT,
  title VARCHAR(255) NOT NULL,
  venue VARCHAR(255),
  start_date DATE,
  end_date DATE,
  floorplan_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE SET NULL
);

CREATE TABLE booths (
  id INT AUTO_INCREMENT PRIMARY KEY,
  exhibition_id INT,
  name VARCHAR(255),
  x INT, y INT, width INT, height INT,
  price_cents INT DEFAULT 0,
  status ENUM('available','booked','blocked') DEFAULT 'available',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (exhibition_id) REFERENCES exhibitions(id) ON DELETE CASCADE
);

CREATE TABLE exhibitors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  company_name VARCHAR(255),
  contact_phone VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  exhibitor_id INT,
  booth_id INT,
  status ENUM('pending','confirmed','cancelled') DEFAULT 'pending',
  amount_cents INT,
  payment_id VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (exhibitor_id) REFERENCES exhibitors(id),
  FOREIGN KEY (booth_id) REFERENCES booths(id)
);

-- add other tables for events, tickets, orders, checkins as needed...
