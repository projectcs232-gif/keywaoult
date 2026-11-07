-- BMNS KeyVault (PHP edition) — MySQL 8+ / MariaDB 10.4+ (XAMPP).
-- phpMyAdmin > SQL tab > paste and run. Safe to re-run; it never drops data.
-- Same schema as the Node version, so an existing bmns_keyvault database works unchanged.

CREATE DATABASE IF NOT EXISTS bmns_keyvault
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bmns_keyvault;

CREATE TABLE IF NOT EXISTS vault_users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  email VARCHAR(320) NOT NULL,
  email_normalized VARCHAR(320) GENERATED ALWAYS AS (LOWER(TRIM(email))) STORED,
  salt_hex CHAR(32) NOT NULL,
  verifier_iv_hex CHAR(24) NOT NULL,
  verifier_data_hex TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_vault_users_email_normalized (email_normalized)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vault_entries (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  account_name VARCHAR(255) NOT NULL,
  account_username VARCHAR(320) NOT NULL DEFAULT '',
  password_iv_hex CHAR(24) NOT NULL,
  password_data_hex TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_vault_entries_user_created (user_id, created_at),
  CONSTRAINT fk_vault_entries_user FOREIGN KEY (user_id)
    REFERENCES vault_users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Records which legacy accounts were imported, to prevent duplicate imports.
CREATE TABLE IF NOT EXISTS legacy_imports (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  legacy_email VARCHAR(320) NOT NULL,
  imported_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_legacy_import_email (legacy_email)
) ENGINE=InnoDB;

-- Login / API throttling (also auto-created by the app if missing).
CREATE TABLE IF NOT EXISTS rate_limits (
  bucket CHAR(64) NOT NULL PRIMARY KEY,
  hits INT NOT NULL,
  window_start INT NOT NULL
) ENGINE=InnoDB;

SHOW TABLES;
