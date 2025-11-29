-- 1. CREACIÓN DE LA BASE DE DATOS
-- Asegura que la base de datos 'paquexpress_db' exista
CREATE DATABASE IF NOT EXISTS paquexpress_db;

-- Selecciona la base de datos para trabajar
USE paquexpress_db;

-- 2. CREACIÓN DE LA TABLA 'users' (Agentes de Reparto)
-- Almacena la información de autenticación de los agentes.
CREATE TABLE users (
    id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    -- password_hash es donde se almacena la contraseña encriptada (bcrypt)
    password_hash VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    INDEX (username) -- Para búsquedas rápidas de login
);

-- 3. CREACIÓN DE LA TABLA 'packages' (Paquetes para Entrega)
-- Almacena los detalles del paquete y la evidencia de entrega.
CREATE TABLE packages (
    id INT NOT NULL AUTO_INCREMENT,
    tracking_code VARCHAR(50) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    
    -- Campos de Evidencia
    is_delivered BOOLEAN DEFAULT FALSE,
    delivery_latitude FLOAT,
    delivery_longitude FLOAT,
    photo_path VARCHAR(255), -- Ruta del archivo de la foto
    delivery_time DATETIME,
    
    -- Clave Foránea que relaciona el paquete con el agente asignado
    agent_id INT, 
    
    PRIMARY KEY (id),
    INDEX (tracking_code),
    
    -- Definición de la Clave Foránea: agent_id referencia a id en la tabla users
    FOREIGN KEY (agent_id) REFERENCES users(id)
);