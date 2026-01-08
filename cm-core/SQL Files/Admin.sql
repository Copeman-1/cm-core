CREATE TABLE IF NOT EXISTS `bans` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `license` VARCHAR(50) NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `reason` TEXT NOT NULL,
    `bannedby` VARCHAR(255) NOT NULL,
    `bannedby_license` VARCHAR(50),
    `expire` BIGINT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_license (license),
    INDEX idx_expire (expire)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `warnings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `license` VARCHAR(50) NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `reason` TEXT NOT NULL,
    `warnedby` VARCHAR(255) NOT NULL,
    `warnedby_license` VARCHAR(50),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_license (license)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `admin_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `admin_license` VARCHAR(50) NOT NULL,
    `admin_name` VARCHAR(255) NOT NULL,
    `action` VARCHAR(50) NOT NULL,
    `target_license` VARCHAR(50),
    `target_name` VARCHAR(255),
    `details` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_admin (admin_license),
    INDEX idx_action (action),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;