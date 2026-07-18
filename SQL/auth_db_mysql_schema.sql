-- Authentication Database Schema for MySQL 8.0
CREATE DATABASE IF NOT EXISTS auth_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE auth_db;

CREATE TABLE users (
    user_id CHAR(36) NOT NULL,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    account_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
    failed_login_attempts INT NOT NULL DEFAULT 0,
    account_locked BOOLEAN NOT NULL DEFAULT FALSE,
    last_login DATETIME,
    password_changed_at DATETIME,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    deleted BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (user_id),
    CONSTRAINT uk_users_username UNIQUE(username),
    CONSTRAINT uk_users_email UNIQUE(email),
    CONSTRAINT uk_users_phone UNIQUE(phone_number),
    CONSTRAINT chk_account_status CHECK (account_status IN ('ACTIVE','LOCKED','DISABLED','SUSPENDED'))
) ENGINE=InnoDB;

CREATE TABLE roles (
    role_id CHAR(36) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE permissions (
    permission_id CHAR(36) PRIMARY KEY,
    permission_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE user_roles (
    user_id CHAR(36) NOT NULL,
    role_id CHAR(36) NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(user_id, role_id),
    CONSTRAINT fk_user_roles_user FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_user_roles_role FOREIGN KEY(role_id) REFERENCES roles(role_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE role_permissions (
    role_id CHAR(36) NOT NULL,
    permission_id CHAR(36) NOT NULL,
    PRIMARY KEY(role_id, permission_id),
    CONSTRAINT fk_role_permissions_role FOREIGN KEY(role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    CONSTRAINT fk_role_permissions_permission FOREIGN KEY(permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE refresh_tokens (
    token_id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    refresh_token VARCHAR(500) NOT NULL,
    expiry_date DATETIME NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_refresh_user FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE otp_verifications (
    otp_id CHAR(36) PRIMARY KEY,
    user_id CHAR(36),
    otp_code VARCHAR(10) NOT NULL,
    purpose VARCHAR(30) NOT NULL,
    expiry_time DATETIME NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_otp_user FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE login_history (
    login_id CHAR(36) PRIMARY KEY,
    user_id CHAR(36),
    login_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    device_name VARCHAR(100),
    browser VARCHAR(100),
    operating_system VARCHAR(100),
    login_status VARCHAR(20),
    failure_reason VARCHAR(255),
    CONSTRAINT fk_login_user FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE password_history (
    history_id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_password_user FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_user_username ON users(username);
CREATE INDEX idx_user_status ON users(account_status);
CREATE INDEX idx_refresh_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_expiry ON refresh_tokens(expiry_date);
CREATE INDEX idx_login_user ON login_history(user_id);
CREATE INDEX idx_login_time ON login_history(login_time);
CREATE INDEX idx_otp_user ON otp_verifications(user_id);
CREATE INDEX idx_otp_expiry ON otp_verifications(expiry_time);

INSERT INTO roles(role_id, role_name, description) VALUES
(UUID(),'ADMIN','System Administrator'),
(UUID(),'CUSTOMER','Customer'),
(UUID(),'SELLER','Seller'),
(UUID(),'SUPPORT','Support Team');

INSERT INTO permissions(permission_id, permission_name, description) VALUES
(UUID(),'USER_READ','Read users'),
(UUID(),'USER_WRITE','Manage users'),
(UUID(),'PRODUCT_READ','Read products'),
(UUID(),'PRODUCT_WRITE','Manage products'),
(UUID(),'ORDER_READ','Read orders'),
(UUID(),'ORDER_WRITE','Manage orders'),
(UUID(),'ROLE_MANAGE','Manage roles');
