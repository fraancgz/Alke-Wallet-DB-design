/* PROYECTO: Alke Wallet - Diseño de Base de Datos
   AUTOR: @fraan_cgz
   
   DECISIONES TÉCNICAS:
   1. Idioma: Todas las entidades y atributos se han definido en inglés para alinearse 
      con los estándares globales de la industria tecnológica y las mejores prácticas 
      de documentación técnica.
      
   2. Convención de Nombres: Las tablas se han nombrado en singular (ej. 'currency', 
      'transaction') debido a que cada tabla representa un modelo de entidad único 
      o "molde" según el diseño conceptual[cite: 17, 133].
      
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
CREATE DATABASE "Alke Wallet";



-- =============================================
-- 2. TABLE DEFINITIONS (DDL)
-- =============================================
CREATE DATABASE Alke Wallet
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

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



-- =============================================
-- 4. DATA SEEDING (DML)
-- =============================================


-- =============================================
-- 5. CONSULTAS DE PRUEBA (QUERIES)
-- =============================================