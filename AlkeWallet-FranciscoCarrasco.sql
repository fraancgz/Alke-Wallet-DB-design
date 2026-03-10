/* PROYECTO: Alke Wallet - Diseño de Base de Datos
   AUTOR: @fraan_cgz
   
   DECISIONES TÉCNICAS:
   1. Idioma: Todas las entidades y atributos se han definido en inglés para alinearse 
      con los estándares globales de la industria tecnológica y las mejores prácticas 
      de documentación técnica.
      
   2. Convención de Nombres: Las tablas se han nombrado en singular (ej. 'currency', 
      'transaction') debido a que cada tabla representa un modelo de entidad único 
      o "molde" según el diseño conceptual
      
   3. Palabras Reservadas: La tabla de usuarios se ha nombrado 'app_user' para evitar 
      conflictos con la palabra reservada 'USER' de SQL, garantizando la compatibilidad 
      entre diferentes motores de bases de datos.
      
   4. Integridad de Datos: Se implementaron tipos NUMERIC para asegurar precisión financiera 
      y restricciones CHECK para aplicar la lógica de negocio directamente a nivel de 
      base de datos.
*/

-- =============================================
-- 1. DATABASE RECREATION
-- =============================================
DROP DATABASE IF EXISTS "Alke Wallet";
CREATE DATABASE "Alke Wallet"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;


-- =============================================
-- 2. TABLE DEFINITIONS (DDL)
-- =============================================
create table app_user(
user_id serial primary key,
name varchar(100) not null,
email varchar unique constraint valid_user check (length(email) > 5),
password varchar not null,
current_balance numeric(15,2) default 0 constraint positive_balance check (current_balance >= 0)
);


create table currency(
currency_id serial primary key,
currency_name varchar(30) not null,
currency_symbol varchar(10) not null
);


create table transaction(
transaction_id serial primary key,
amount numeric(15,2) not null default 0 constraint positive_amount check (amount >= 0),
transaction_date TIMESTAMP not null default current_timestamp,
sender_user_id int not null,
receiver_user_id int not null,
currency_id int not null,
foreign key (sender_user_id) references app_user(user_id),
foreign key (receiver_user_id) references app_user(user_id),
foreign key (currency_id) references currency(currency_id)
);


-- =============================================
-- 3. INDEXES & OPTIMIZATION
-- =============================================
/*
   INDICE SIMPLE

   Creo indices simples para los que envian y reciben transacciones, para agilizar las 
   busquedas directas. Esto evita que se consulten todas las columnas de las tablas
   y se enfoque solo en la solicitada y encontrado los datos muestra todo
*/
create index idx_sender_user_id on transaction(sender_user_id);
create index idx_receiver_user_id on transaction(receiver_user_id);

/*
   INDICE COMPUESTO
*/
-- Optimiza el historial cronológico de egresos por usuario
create index idx_sender_date on transaction(sender_user_id, transaction_date);

-- Optimiza la búsqueda de transferencias entre pares 
create index idx_sender_receiver on transaction(sender_user_id, receiver_user_id);

-- Optimizaa reportes de egresos por usuario y divisa.
create index idx_transaction_user_currency on transaction(sender_user_id, currency_id);

-- =============================================
-- 4. DATA SEEDING (DML)
-- =============================================
--                        currency
INSERT INTO currency (currency_name, currency_symbol) VALUES 
('Peso Chileno', 'CLP'), -- Moneda base para tus pruebas en Buin
('Dólar Estadounidense', 'USD'), -- Para probar transacciones internacionales
('Euro', 'EUR'); -- Para verificar que el sistema soporta múltiples divisas

--                        app_user
INSERT INTO app_user (name, email, password, current_balance) VALUES 
('Francisco González', 'fraan_cgz@example.com', 'pass123', 850000.50), 
('Javier Iturra', 'j.iturra@example.com', 'secure456', 120000.00),
('Ignacia Silva', 'isi@example.com', 'valida789', 450000.00),
('Erick González', 'erick.g@example.com', 'bro789', 950000.00),    
('Valentina Paz', 'valepaz@example.com', 'paz123', 320000.75),
('Andrés Castro', 'acastro@example.com', 'andres456', 15000.00),
('Camila Soto', 'csoto@example.com', 'cami789', 670000.20),
('Roberto Muñoz', 'rmunoz@example.com', 'rob123', 0.00),
('Elena Rivas', 'erivas@example.com', 'elena456', 1100000.00),    
('Mauricio Vera', 'mvera@example.com', 'mau789', 540000.10);

--                        transaction
INSERT INTO transaction (sender_user_id, receiver_user_id, amount, currency_id, transaction_date) VALUES 
(1, 4, 12000.00, 1, '2026-03-01 08:30:00'), -- Francisco -> Erick (CLP)
(4, 9, 50.00, 2, '2026-03-01 10:15:00'),    -- Erick -> Elena (USD)
(9, 10, 3500.00, 1, '2026-03-01 12:45:00'),   -- Elena -> Mauricio (CLP)
(10, 3, 10.00, 3, '2026-03-02 09:20:00'),    -- Mauricio -> Ignacia (EUR)
(2, 5, 8000.00, 1, '2026-03-02 14:10:00'),    -- Javier -> Valentina (CLP)
(5, 6, 5.50, 2, '2026-03-02 18:30:00'),      -- Valentina -> Andrés (USD)
(7, 2, 25000.00, 1, '2026-03-03 07:45:00'),  -- Camila -> Javier (CLP)
(8, 7, 100.00, 2, '2026-03-03 11:00:00'),    -- Roberto -> Camila (USD)
(9, 1, 15.00, 3, '2026-03-03 15:30:00'),     -- Elena -> Francisco (EUR)
(6, 8, 4000.00, 1, '2026-03-04 10:00:00'),    -- Andrés -> Roberto (CLP)
(1, 10, 12.00, 2, '2026-03-04 13:20:00'),    -- Francisco -> Mauricio (USD)
(3, 7, 9000.00, 1, '2026-03-04 16:45:00'),    -- Ignacia -> Camila (CLP)
(4, 2, 20.00, 3, '2026-03-05 08:15:00'),     -- Erick -> Javier (EUR)
(5, 9, 15000.00, 1, '2026-03-05 12:00:00'),  -- Valentina -> Elena (CLP)
(10, 5, 2.00, 2, '2026-03-05 19:30:00'),     -- Mauricio -> Valentina (USD)
(7, 4, 3000.00, 1, '2026-03-06 09:10:00'),    -- Camila -> Erick (CLP)
(2, 6, 5.00, 3, '2026-03-06 14:50:00'),      -- Javier -> Andrés (EUR)
(8, 1, 1000.00, 1, '2026-03-06 17:05:00'),    -- Roberto -> Francisco (CLP)
(6, 3, 45.00, 2, '2026-03-07 11:25:00'),     -- Andrés -> Ignacia (USD)
(4, 10, 2200.00, 1, '2026-03-07 20:00:00');   -- Erick -> Mauricio (CLP)

-- =============================================
-- 5. CONSULTAS DE PRUEBA (QUERIES)
-- =============================================
-- Consulta para obtener el nombre de la moneda elegida por un usuario específico. 
select u.name, c.currency_name from transaction t
join app_user u
on t.sender_user_id = u.user_id
join currency c
on c.currency_id = t.currency_id
where u.user_id = 1
order by  c.currency_name;

-- Consulta para obtener todas las transacciones registradas. 
select 
	transaction_id as "N° Transacción",
	u_sender.name as "Enviado por",
	transaction_date as Fecha, 
	u_receiver.name as "Recibido por",
	amount as Monto,
	currency_symbol as Divisa
from transaction t
join app_user u_sender
on u_sender.user_id = t.sender_user_id
join app_user u_receiver
on u_receiver.user_id = t.receiver_user_id
join currency c
on c.currency_id = t.currency_id
order by t.transaction_id;


-- Consulta para obtener todas las transacciones realizadas por un usuario específico
-- Entiendo transaccion realizada a la accion de enviar transacción, recibir una es pasivo,
-- por lo que no la considero 
select 
	transaction_id as "N° Transacción",
	u_sender.name as "Enviado por",
	transaction_date as Fecha, 
	u_receiver.name as "Recibido por",
	amount as Monto,
	currency_symbol as Divisa
from transaction t
join app_user u_sender
on u_sender.user_id = t.sender_user_id
join app_user u_receiver
on u_receiver.user_id = t.receiver_user_id
join currency c
on c.currency_id = t.currency_id
where u_sender.user_id = 1
order by t.transaction_date desc;

-- Sentencia DML para modificar el campo correo electrónico de un usuario específico. 
update app_user 
set email = 'f.gonzalez@alkemy.com'
where user_id = 1;
 
-- Sentencia para eliminar los datos de una transacción (eliminado de la fila completa) 
delete 
from transaction
where transaction_id = 13;


--  Practicar sub‑consultas para obtener el total de transacciones por usuario. 
select count(*) as "Total_transacciones_por_usuario"
from transaction
where sender_user_id in (select user_id from app_user where user_id = 1)
or receiver_user_id in (select user_id from app_user where user_id = 1);

-- Crear una vista que muestre el top‑5 de usuarios con mayor saldo. 
create or replace view v_top_five_user_balance as
select name, current_balance
from app_user
order by current_balance desc
limit 5;


-- =============================================
-- 6. DEMOSTRACIÓN DE TRANSACCIÓN ATÓMICA 
-- =============================================

-- =============================================
-- A. Actualizar el saldo de un usuario luego de una transacción.
INSERT INTO transaction (sender_user_id, receiver_user_id, amount, currency_id, transaction_date)
VALUES (1, 2, 5000, 1, NOW());

UPDATE app_user SET current_balance = current_balance - 5000 WHERE user_id = 1;

UPDATE app_user SET current_balance = current_balance + 5000 WHERE user_id = 2;
-- =============================================


-- =============================================
-- B. Implementar una transacción con START TRANSACTION, COMMIT y ROLLBACK.
-- Escenario: Usuario 1 le transfiere 100.000 CLP a usuario 6
start TRANSACTION;

update app_user
set current_balance = current_balance - 100000
where user_id = 1;

update app_user
set current_balance = current_balance + 100000
where user_id = 6;

insert into transaction (sender_user_id, receiver_user_id, amount, currency_id, transaction_date)
values(1, 6, 100000, 1, now());

COMMIT;
-- En caso de un usuario no disponer de saldo suficiente, el check se activará y no
-- permitirá seguir realizando consultas hasta un commit o rolback
-- =============================================


-- =============================================
-- C. Simular un error de integridad referencial y revertir la operación. 
-- Escenario: Usuario 1 le transfiere 3.500 CLP a usuario 550, usuario que no existe
start TRANSACTION;

update app_user
set current_balance = current_balance - 3500
where user_id = 1;

update app_user
set current_balance = current_balance + 3500
where user_id = 550;

-- Si se intenta consultar algo ahora,  dirá que la transacción está ABORTADA.
insert into transaction (sender_user_id, receiver_user_id, amount, currency_id, transaction_date)
values(1, 550, 3500, 1, now());

COMMIT;

-- Con el comando rollback se aborta la transacción en curso. Revierte los cambios y 
-- permite volver a ejecutar comandos normalmente
ROLLBACK;
-- =============================================


