SET FOREIGN_KEY_CHECKS=0;
CREATE DATABASE IF NOT EXISTS `exhibitiondb` DEFAULT CHARACTER SET = 'utf8mb4' COLLATE = 'utf8mb4_unicode_ci';
USE `exhibitiondb`;

-- accounting_transactions
CREATE TABLE IF NOT EXISTS `accounting_transactions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `transaction_type` VARCHAR(20) NOT NULL, -- income / expenditure
  `category` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `amount` DOUBLE NOT NULL,
  `transaction_date` DATE NOT NULL,
  `user_id` INT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `payment_id` INT,
  `event_session_id` INT,
  CONSTRAINT `acctx_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- app_meta
CREATE TABLE IF NOT EXISTS `app_meta` (
  `key` VARCHAR(255) PRIMARY KEY,
  `value` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- base_rates
CREATE TABLE IF NOT EXISTS `base_rates` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `rate` DOUBLE NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- booking_edits
CREATE TABLE IF NOT EXISTS `booking_edits` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `username` VARCHAR(255) NOT NULL,
  `proposed_data` TEXT NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'pending',
  `request_date` DATETIME NOT NULL,
  `rejection_reason` TEXT,
  `user_notified` TINYINT(1) DEFAULT 0,
  CONSTRAINT `booking_edits_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
  -- note: original referenced bookings_old — verify if that mapping should point to `bookings` instead
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- booking_spaces
CREATE TABLE IF NOT EXISTS `booking_spaces` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT NOT NULL,
  `space_id` INT NOT NULL,
  CONSTRAINT `booking_spaces_booking_fk` FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE CASCADE,
  CONSTRAINT `booking_spaces_space_fk` FOREIGN KEY (`space_id`) REFERENCES `spaces`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- booking_staff
CREATE TABLE IF NOT EXISTS `booking_staff` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `dob` DATE NULL,
  `address` TEXT,
  `phone` VARCHAR(64) NOT NULL,
  `aadhaar` VARCHAR(64) UNIQUE,
  `photo_path` TEXT,
  `role` VARCHAR(100),
  `secondary_phone` VARCHAR(64),
  `event_session_id` INT,
  `is_active` TINYINT(1) DEFAULT 1,
  CONSTRAINT `booking_staff_event_session_fk` FOREIGN KEY (`event_session_id`) REFERENCES `event_sessions`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- bookings
CREATE TABLE IF NOT EXISTS `bookings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `space_id` INT,
  `booking_date` DATETIME NOT NULL,
  `exhibitor_name` VARCHAR(255),
  `facia_name` VARCHAR(255),
  `product_category` VARCHAR(255),
  `contact_person` VARCHAR(255),
  `full_address` TEXT,
  `contact_number` VARCHAR(64),
  `secondary_number` VARCHAR(64),
  `id_proof` TEXT,
  `rent_amount` DOUBLE,
  `discount` DOUBLE,
  `advance_amount` DOUBLE,
  `due_amount` DOUBLE,
  `form_submitted` TINYINT(1) DEFAULT 0,
  `booking_status` VARCHAR(50) DEFAULT 'active',
  `vacated_date` DATE,
  `client_id` INT,
  `event_session_id` INT,
  `rebooked_from_booking_id` INT,
  `notes` TEXT,
  CONSTRAINT `bookings_space_fk` FOREIGN KEY (`space_id`) REFERENCES `spaces`(`id`) ON DELETE SET NULL,
  CONSTRAINT `bookings_client_fk` FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`) ON DELETE SET NULL,
  CONSTRAINT `bookings_event_session_fk` FOREIGN KEY (`event_session_id`) REFERENCES `event_sessions`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- clients
CREATE TABLE IF NOT EXISTS `clients` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `contact_person` VARCHAR(255),
  `contact_number` VARCHAR(64),
  `full_address` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- electric_bill_edits
CREATE TABLE IF NOT EXISTS `electric_bill_edits` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `electric_bill_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `username` VARCHAR(255) NOT NULL,
  `proposed_data` TEXT NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'pending',
  `request_date` DATETIME NOT NULL,
  `rejection_reason` TEXT,
  `user_notified` TINYINT(1) DEFAULT 0,
  CONSTRAINT `electric_bill_edits_bill_fk` FOREIGN KEY (`electric_bill_id`) REFERENCES `electric_bills`(`id`) ON DELETE CASCADE,
  CONSTRAINT `electric_bill_edits_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- electric_bills
CREATE TABLE IF NOT EXISTS `electric_bills` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT,
  `bill_date` DATE,
  `items_json` TEXT,
  `total_amount` DOUBLE,
  `remarks` TEXT,
  `sl_no` VARCHAR(255),
  `event_session_id` INT,
  CONSTRAINT `electric_bills_booking_fk` FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE SET NULL,
  CONSTRAINT `electric_bills_event_session_fk` FOREIGN KEY (`event_session_id`) REFERENCES `event_sessions`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- electric_items
CREATE TABLE IF NOT EXISTS `electric_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `service_charge` DOUBLE DEFAULT 0,
  `fitting_charge` DOUBLE DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- event_sessions
CREATE TABLE IF NOT EXISTS `event_sessions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `location` VARCHAR(255),
  `start_date` DATE,
  `end_date` DATE,
  `is_active` TINYINT(1) DEFAULT 0,
  `address` TEXT,
  `place` VARCHAR(255),
  `logo_path` TEXT,
  `is_deleted` TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- exhibition_details
CREATE TABLE IF NOT EXISTS `exhibition_details` (
  `id` INT PRIMARY KEY,
  `address` TEXT,
  `location` TEXT,
  `place` VARCHAR(255),
  `logo_path` TEXT,
  `name` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- logs
CREATE TABLE IF NOT EXISTS `logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `user_id` INT,
  `username` VARCHAR(255),
  `action` VARCHAR(255),
  `details` TEXT,
  `event_session_id` INT,
  CONSTRAINT `logs_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_logs_action` (`action`),
  INDEX `idx_logs_event_session_id` (`event_session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- material_defaults
CREATE TABLE IF NOT EXISTS `material_defaults` (
  `id` INT PRIMARY KEY,
  `free_tables` INT DEFAULT 1,
  `free_chairs` INT DEFAULT 2,
  `plywood_free` INT DEFAULT 0,
  `rod_free` INT DEFAULT 0,
  `table_free` INT DEFAULT 0,
  `chair_free` INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- material_history
CREATE TABLE IF NOT EXISTS `material_history` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `material_id` INT NOT NULL,
  `status` VARCHAR(100) NOT NULL,
  `user_id` INT,
  `username` VARCHAR(255),
  `client_id` INT,
  `timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `event_session_id` INT,
  `notes` TEXT,
  CONSTRAINT `material_history_material_fk` FOREIGN KEY (`material_id`) REFERENCES `material_stock`(`id`) ON DELETE CASCADE,
  CONSTRAINT `material_history_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `material_history_client_fk` FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- material_issue_edits
CREATE TABLE IF NOT EXISTS `material_issue_edits` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `material_issue_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `username` VARCHAR(255) NOT NULL,
  `proposed_data` TEXT NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'pending',
  `request_date` DATETIME NOT NULL,
  `rejection_reason` TEXT,
  `user_notified` TINYINT(1) DEFAULT 0,
  CONSTRAINT `material_issue_edits_issue_fk` FOREIGN KEY (`material_issue_id`) REFERENCES `material_issues`(`id`) ON DELETE CASCADE,
  CONSTRAINT `material_issue_edits_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- material_issues
CREATE TABLE IF NOT EXISTS `material_issues` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `client_id` INT,
  `stall_number` VARCHAR(255),
  `camp` VARCHAR(255),
  `plywood_free` INT,
  `table_free` INT,
  `chair_free` INT,
  `rod_free` INT,
  `plywood_paid` INT,
  `table_paid` INT,
  `chair_paid` INT,
  `table_numbers` TEXT,
  `chair_numbers` TEXT,
  `total_payable` DOUBLE,
  `advance_paid` DOUBLE,
  `balance_due` DOUBLE,
  `notes` TEXT,
  `issue_date` DATE DEFAULT (CURRENT_DATE),
  `sl_no` VARCHAR(255),
  `event_session_id` INT,
  CONSTRAINT `material_issues_client_fk` FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`) ON DELETE SET NULL,
  CONSTRAINT `material_issues_event_session_fk` FOREIGN KEY (`event_session_id`) REFERENCES `event_sessions`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- material_stock
CREATE TABLE IF NOT EXISTS `material_stock` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `unique_id` VARCHAR(255) NOT NULL UNIQUE,
  `qr_code_path` TEXT,
  `status` VARCHAR(50) DEFAULT 'Available',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `issued_to_client_id` INT,
  `sequence` INT,
  `event_session_id` INT,
  CONSTRAINT `material_stock_client_fk` FOREIGN KEY (`issued_to_client_id`) REFERENCES `clients`(`id`) ON DELETE SET NULL,
  CONSTRAINT `material_stock_event_session_fk` FOREIGN KEY (`event_session_id`) REFERENCES `event_sessions`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- payment_edits
CREATE TABLE IF NOT EXISTS `payment_edits` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `payment_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `username` VARCHAR(255) NOT NULL,
  `proposed_data` TEXT NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'pending',
  `request_date` DATETIME NOT NULL,
  `rejection_reason` TEXT,
  `user_notified` TINYINT(1) DEFAULT 0,
  CONSTRAINT `payment_edits_payment_fk` FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE CASCADE,
  CONSTRAINT `payment_edits_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- payments
CREATE TABLE IF NOT EXISTS `payments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT NOT NULL,
  `receipt_number` VARCHAR(255) NOT NULL,
  `payment_date` DATE,
  `rent_paid` DOUBLE DEFAULT 0,
  `electric_paid` DOUBLE DEFAULT 0,
  `material_paid` DOUBLE DEFAULT 0,
  `shed_paid` DOUBLE DEFAULT 0,
  `temp_receipt_number` VARCHAR(255),
  `payment_mode` VARCHAR(100),
  `cash_paid` DOUBLE DEFAULT 0,
  `upi_paid` DOUBLE DEFAULT 0,
  `event_session_id` INT,
  `remarks` TEXT,
  CONSTRAINT `payments_booking_fk` FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE CASCADE,
  CONSTRAINT `payments_event_session_fk` FOREIGN KEY (`event_session_id`) REFERENCES `event_sessions`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- rides
CREATE TABLE IF NOT EXISTS `rides` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL UNIQUE,
  `is_active` TINYINT(1) DEFAULT 1,
  `rate` DOUBLE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- shed_allocations
CREATE TABLE IF NOT EXISTS `shed_allocations` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT NOT NULL,
  `shed_id` INT NOT NULL,
  `allocation_date` DATE,
  `event_session_id` INT,
  CONSTRAINT `shed_allocations_booking_fk` FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE CASCADE,
  CONSTRAINT `shed_allocations_shed_fk` FOREIGN KEY (`shed_id`) REFERENCES `sheds`(`id`) ON DELETE CASCADE,
  CONSTRAINT `shed_allocations_event_session_fk` FOREIGN KEY (`event_session_id`) REFERENCES `event_sessions`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- shed_bills
CREATE TABLE IF NOT EXISTS `shed_bills` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT,
  `bill_date` DATE,
  `description` TEXT,
  `amount` DOUBLE,
  `event_session_id` INT,
  CONSTRAINT `shed_bills_booking_fk` FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE SET NULL,
  CONSTRAINT `shed_bills_event_session_fk` FOREIGN KEY (`event_session_id`) REFERENCES `event_sessions`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- sheds
CREATE TABLE IF NOT EXISTS `sheds` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL UNIQUE,
  `size` VARCHAR(255),
  `rent` DOUBLE,
  `status` VARCHAR(50) DEFAULT 'Available',
  `is_active` TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- spaces
CREATE TABLE IF NOT EXISTS `spaces` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `type` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `size` VARCHAR(255),
  `rent_amount` DOUBLE,
  `facilities` TEXT,
  `location` VARCHAR(255),
  `status` VARCHAR(50) DEFAULT 'Available',
  `is_active` TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- sqlite_sequence (we can ignore, but create for compatibility)
CREATE TABLE IF NOT EXISTS `sqlite_sequence` (
  `name` VARCHAR(255),
  `seq` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- staff_settlements
CREATE TABLE IF NOT EXISTS `staff_settlements` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `staff_id` INT NOT NULL,
  `event_session_id` INT NOT NULL,
  `settlement_date` DATE NOT NULL,
  `expected_amount` DOUBLE NOT NULL,
  `actual_amount` DOUBLE NOT NULL,
  `difference` DOUBLE NOT NULL,
  `notes` TEXT,
  `status` VARCHAR(50) NOT NULL DEFAULT 'unsettled',
  `settled_by_user_id` INT,
  `settled_on_date` DATE,
  CONSTRAINT `staff_settlements_staff_fk` FOREIGN KEY (`staff_id`) REFERENCES `booking_staff`(`id`) ON DELETE CASCADE,
  CONSTRAINT `staff_settlements_event_session_fk` FOREIGN KEY (`event_session_id`) REFERENCES `event_sessions`(`id`) ON DELETE CASCADE,
  CONSTRAINT `staff_settlements_user_fk` FOREIGN KEY (`settled_by_user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ticket_categories
CREATE TABLE IF NOT EXISTS `ticket_categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ticket_distributions
CREATE TABLE IF NOT EXISTS `ticket_distributions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `distribution_date` DATE NOT NULL,
  `staff_id` INT NOT NULL,
  `rate_id` INT,
  `stock_id` INT,
  `distributed_start_number` INT,
  `distributed_end_number` INT,
  `returned_start_number` INT,
  `settlement_date` DATE,
  `tickets_sold` INT,
  `calculated_revenue` DOUBLE,
  `upi_amount` DOUBLE,
  `cash_amount` DOUBLE,
  `status` VARCHAR(50) DEFAULT 'Distributed',
  `settled_by_user_id` INT,
  `event_session_id` INT,
  CONSTRAINT `ticket_distributions_staff_fk` FOREIGN KEY (`staff_id`) REFERENCES `booking_staff`(`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_distributions_rate_fk` FOREIGN KEY (`rate_id`) REFERENCES `ticket_rates`(`id`) ON DELETE SET NULL,
  CONSTRAINT `ticket_distributions_stock_fk` FOREIGN KEY (`stock_id`) REFERENCES `ticket_stock`(`id`) ON DELETE SET NULL,
  CONSTRAINT `ticket_distributions_event_session_fk` FOREIGN KEY (`event_session_id`) REFERENCES `event_sessions`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ticket_rates
CREATE TABLE IF NOT EXISTS `ticket_rates` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL UNIQUE,
  `is_active` TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ticket_stock
CREATE TABLE IF NOT EXISTS `ticket_stock` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `category_id` INT,
  `rate` DOUBLE,
  `color` VARCHAR(100),
  `start_number` INT NOT NULL,
  `end_number` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `status` VARCHAR(50) DEFAULT 'Available',
  `event_session_id` INT,
  `entry_date` DATE,
  CONSTRAINT `ticket_stock_category_fk` FOREIGN KEY (`category_id`) REFERENCES `ticket_categories`(`id`) ON DELETE SET NULL,
  CONSTRAINT `ticket_stock_event_session_fk` FOREIGN KEY (`event_session_id`) REFERENCES `event_sessions`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- users
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(255) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `role` VARCHAR(100) NOT NULL DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- write_offs
CREATE TABLE IF NOT EXISTS `write_offs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT NOT NULL,
  `amount` DOUBLE NOT NULL,
  `reason` TEXT,
  `write_off_date` DATE NOT NULL,
  `user_id` INT,
  `event_session_id` INT,
  CONSTRAINT `write_offs_booking_fk` FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE CASCADE,
  CONSTRAINT `write_offs_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `write_offs_event_session_fk` FOREIGN KEY (`event_session_id`) REFERENCES `event_sessions`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS=1;
