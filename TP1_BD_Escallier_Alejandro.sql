/* --------------------- 1.creacion de base de datos y tablas --------------------- */
CREATE DATABASE aerolinea_er;
USE aerolinea_er;

CREATE TABLE pasajero (
	pasajero_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    apellido VARCHAR(30) NOT NULL,
    email VARCHAR(30) NOT NULL,
    tipo_documento VARCHAR(20) NOT NULL,
    nro_documentO VARCHAR(20) NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_alta DATETIME NOT NULL
);

CREATE TABLE vuelo (
	vuelo_id INT AUTO_INCREMENT PRIMARY KEY,
    origen VARCHAR(50) NOT NULL,
    destino VARCHAR(50) NOT NULL,
    fecha_salida DATETIME NOT NULL,
    fecha_estimada_arribo DATETIME NOT NULL,
    combustible DECIMAL (5.2) NOT NULL DEFAULT 100.00,
    capacidad INT NOT NULL DEFAULT 77 CHECK (capacidad BETWEEN 1 AND 100)
);

CREATE TABLE reserva (
	reserva_id INT AUTO_INCREMENT PRIMARY KEY,
    pasajero_id INT NOT NULL,
    vuelo_id INT NOT NULL,
    fecha_reserva DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    monto DECIMAL(7.2) NOT NULL DEFAULT 777.00,
    forma_pago ENUM('Efectivo', 'transferencia', 'Tarjeta') NOT NULL DEFAULT 'Tarjeta',
    FOREIGN KEY (pasajero_id) REFERENCES pasajero(pasajero_id),
    FOREIGN KEY (vuelo_id) REFERENCES vuelo(vuelo_id)
);

CREATE TABLE avion (
	avion_id INT AUTO_INCREMENT PRIMARY KEY,
    vuelo_id INT NOT NULL,
    marca VARCHAR (50) NOT NULL DEFAULT 'Boeing',
    modelo VARCHAR(20) NOT NULL DEFAULT '767',
    anio_contratacion YEAR NOT NULL DEFAULT 2022,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (vuelo_id) REFERENCES vuelo(vuelo_id)
);


/* --------------------- 2. inserccion de datos --------------------- */
INSERT INTO pasajero (nombre, apellido, email, tipo_documento, nro_documento, fecha_alta)
VALUES ('Alejandro', 'Escallier', 'alejandroescallier@gmail.com', 'DNI', '46084552', '2025-09-06 12:00:00');

INSERT INTO vuelo (origen, destino, fecha_salida, fecha_estimada_arribo, combustible, capacidad)
VALUES ('Buenos aires', 'Tokyo', '2025-09-07 12:00:00', '2025-09-08 12:00:00', 700.00, 44);

INSERT INTO reserva (pasajero_id, vuelo_id, monto, forma_pago)
VALUES (1, 1, 2000.00, 'Tarjeta');

INSERT INTO avion (vuelo_id, marca, modelo, anio_contratacion, activo)
VALUES (1, 'Airbus', 'A777', 2020, TRUE);

INSERT INTO pasajero (nombre, apellido, email, tipo_documento, nro_documento, fecha_alta)
VALUES 
	('Leonardo', 'Esquevel', 'leonardoesquevel@gmail.com', 'DNI', '46798882','2025-09-09 12:00:00'),
    ('Tiziano', 'Godtela', 'tizianogodtela@gmail.com', 'DNI', '46484521','2025-09-10 12:00:00'),
    ('Juan', 'Espinola', 'juanespinola@gmail.com', 'DNI', '46376797','2025-09-11 12:00:00');
SELECT * FROM pasajero;

INSERT INTO vuelo (origen, destino, fecha_salida, fecha_estimada_arribo, combustible, capacidad)
VALUES
	('Buenos Aires', 'New York', '2025-09-12 12:00:00', '2025-09-13 12:00:00', 900.00, 99),
    ('Buenos Aires', 'Amsterdan', '2025-09-14 12:00:00', '2025-09-15 12:00:00', 800.00, 66),
    ('Buenos aires', 'Argelia', '2025-09-16 12:00:00', '2025-09-17 12:00:00', 500.00, 88);

INSERT INTO reserva (pasajero_id, vuelo_id, monto, forma_pago)
VALUES
	(2, 2, 2000.00, 'Transferencia'),
    (3, 3, 3000.00, 'Tarjeta'),
    (4, 4, 4000.00, 'Efectivo');
    
INSERT INTO avion (vuelo_id, marca, modelo, anio_contratacion, activo)
VALUES
	(2, 'Boeing', '737', 2019, TRUE),
    (3, 'Airbus', 'A444', 2021, TRUE),
    (4, 'Boeing', '747', 2023, TRUE);


/* --------------------- 3. Modifiacion de tablas --------------------- */
ALTER TABLE pasajero
ADD COLUMN telefono VARCHAR(20) AFTER nro_documento;

ALTER TABLE reserva
MODIFY COLUMN monto DECIMAL(10,2) NOT NULL DEFAULT 1000.00;

ALTER TABLE pasajero
DROP COLUMN telefono;

/* 3.4 No cambio el nombre de la columna fecha_alta a fecha_registro porque ya cree una clase así, lo consideré necesario para la reserva, una fecha de inicio y fin de la reserva*/

ALTER TABLE reserva
ADD COLUMN categoria VARCHAR(20) AFTER monto;

/* 3.6 Cree la columna fecha_registro en la tabla pasajero. 
No elimino ninguna columna porque las considero necesarias a todas. Pensaba que combustible podria no usarse, pero me parece coherente tenerlo.
O que reserva_id podria unirse con pasajero_id y estar acoplados una con la otra, usar una id en vez de dos, pero una cosa es la id de la reserva dentro de todas las que hay en la aerolinea y otra cosa es la cantidad 
de pasajeros que hay en un vuelo, aunque tambien ese pasajero_id podria estar reservado para todos lo que hay registrados en la aerolinea, pero en este caso no lo tomo así.*/

/* 3.7 De esta forma se tiene control casi exacto en cuento al tiempo que lleva el avion. 
Y que por default los aviones sean del año 2022 tampoco tenia mucho sentido, a menos que haya alguna especie de ley aerea de seguridad o algo así.*/
ALTER TABLE avion
MODIFY COLUMN anio_contratacion VARCHAR(20);

UPDATE avion
SET anio_contratacion = CONCAT(anio_contratacion, '-01-01 00:00:00')
WHERE avion_id > 0;

ALTER TABLE avion
CHANGE COLUMN anio_contratacion fecha_contratacion DATETIME NOT NULL;


/* --------------------- 4. gestion de usuaarios y roles --------------------- */
CREATE USER 'usuario_aerolinea' IDENTIFIED BY 'contraseña';
GRANT SELECT ON aerolineas_er.* TO 'usuario_aerolinea';

CREATE ROLE 'rol_reserva';
GRANT SELECT, INSERT, UPDATE ON aerolinea_er.pasajero TO 'rol_reserva';
GRANT SELECT, INSERT, UPDATE ON aerolinea_er.reserva TO 'rol_reserva';

CREATE USER 'usuario_pasajero_reserva' IDENTIFIED BY 'contraseña';
GRANT 'rol_reserva' TO 'usuario_pasajero_reserva';

GRANT DELETE ON aerolinea_er.pasajero TO 'usuario_pasajero_reserva';
GRANT DELETE ON aerolinea_er.reserva TO 'usuario_pasajero_reserva';

REVOKE DELETE ON aerolinea_er.pasajero FROM 'usuario_pasajero_reserva';
REVOKE DELETE ON aerolinea_er.reserva FROM 'usuario_pasajero_reserva';

GRANT 'usuario_pasajero_reserva' TO 'usuario_aerolinea';

ALTER USER 'usuario_pasajero_reserva' IDENTIFIED BY 'nuevacontraseña';

DROP USER 'usuario_aerolinea';

DROP ROLE 'rol_reserva';

CREATE USER 'usuario_admin' IDENTIFIED BY 'admincontraseña';
GRANT ALL PRIVILEGES ON aerolinea_er.* TO 'usuario_admin';


/* --------------------- 5. consultas condicionadas --------------------- */
SELECT *
FROM pasajero
WHERE apellido = 'Esquevel' /*el ejercicio dice 'Gomez', pero como no hay nadie con ese apellido cargado en la base todavia, uso uno que se que sí está*/
	AND email LIKE '%gmail.com%';
    
/*5.2. Listar los aviones con capacidad mayor o igual 150 o menor o igual a 300.
Listé los vuelos que tienen capacidad de entre 0 y 100, porque la columna capacidad está dentro de vuelo, no dentro de avion*/
SELECT *
FROM vuelo
WHERE capacidad BETWEEN 0 AND 100;

SELECT *
FROM reserva
WHERE monto > 100000 /*Listé los montos mayores a 100.000*/
	AND forma_pago = 'Tarjeta';

SELECT *
FROM pasajero
WHERE nombre LIKE 'A%'
	OR nombre LIKE 'J%';
    
SELECT *
FROM vuelo
WHERE origen = 'Buenos Aires';


/* --------------------- 6. consultas ordenadas --------------------- */
SELECT*
FROM pasajero
ORDER BY fecha_registro DESC, apellido ASC;

SELECT *
FROM reserva
ORDER BY monto DESC, forma_pago ASC;

SELECT *
FROM vuelo
ORDER BY fecha_salida ASC; /*elegí listar por fecha_salida porque antes ya habia listado por fecha_registro que lo considero una entrada y ahora algo de "salida" (se podria decir)*/

SELECT *
FROM vuelo
ORDER BY capacidad DESC; /*elegí listar los vuelos por capacidad porque me parece que todavia no interactué mucho con esa columna, mas que la carga de datos*/


/* --------------------- 7. consultas agrupadas --------------------- */
SELECT pasajero_id, COUNT(*) AS total_reservas
FROM reserva
GROUP BY pasajero_id;

SELECT forma_pago, SUM(monto) AS total_ventas
FROM reserva
GROUP BY forma_pago;

SELECT origen, COUNT(*) AS cantidad_vuelos
FROM vuelo
GROUP BY origen;

SELECT destino, COUNT(*) AS cantidad_vuelos
FROM vuelo
GROUP BY destino;/*elegí listar los vuelos por destino porque no interactué mucho con esa columna (como en el punto 6.3)*/


/* --------------------- 8. operaciones ABM de datos --------------------- */
UPDATE pasajero
SET email = 'alejandroescallier@hotmail.com'
WHERE pasajero_id = 1;

UPDATE reserva
SET monto = 7000.00
WHERE reserva_id = 1;

DELETE FROM reserva
WHERE reserva_id = 3; /*elegí eliminar la reserva de este id porque justo estaba hablando con un amigo con el mismo nombre que el id cargado*/

DELETE FROM avion
WHERE activo = 0;

UPDATE vuelo
SET fecha_salida = '2025-09-06 07:07:07'
WHERE vuelo_id = 1;

DELETE FROM avion
WHERE avion_id = 3; /*elegí eliminar este avion porque ya antes eliminé la reserva del id 3 y ahora tambien elegí el id 3*/

/* --------------------------------------------------------------- ACLARACIONES --------------------------------------------------------------- */
/* Durante todo el trabajo utilicé DESCRIBE y SELECT para ver si iban bien los avances y creaciones, a modo de chequeo previo*/