-- Mailin Villan SPRINT4 02/12/2024

-- -------------------------------- NIVEL 1 ------------------------

-- Creamos la base de datos
    CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

-- Creo la tabla companies
   
    CREATE TABLE IF NOT EXISTS companies (
  company_id VARCHAR(15) PRIMARY KEY NOT NULL,
  company_name VARCHAR(255),
  phone VARCHAR(15),
  email VARCHAR(100),
  country VARCHAR(100),
  website VARCHAR(255)
);
 

-- Creo la tabla credit_cards
 
CREATE TABLE IF NOT EXISTS credit_cards (
  id VARCHAR(15) PRIMARY KEY NOT NULL,
  user_id INT DEFAULT NULL,
  iban VARCHAR(50),
  pan VARCHAR(50),
  pin VARCHAR(4),
  cvv int,
  track1 VARCHAR(255),
  track2 VARCHAR(255),
  expiring_date VARCHAR(20)
  ) ;

-- Creo la tabla users

CREATE TABLE IF NOT EXISTS users(
  id INT PRIMARY KEY,
  name VARCHAR(100),
  surname VARCHAR(100),
  phone VARCHAR(150),
  email VARCHAR(150),
  birth_date VARCHAR(100),
  country VARCHAR(150),
  city VARCHAR(150),
  postal_code VARCHAR(100),
  address VARCHAR(255)
  );


-- Creo la tabla transactions
CREATE TABLE IF NOT EXISTS transactions (
  id VARCHAR(255) PRIMARY KEY NOT NULL,
  card_id VARCHAR(15) REFERENCES credit_cards(id),
  business_id VARCHAR(15) REFERENCES companies(company_id),
  timestamp TIMESTAMP,
  amount DECIMAL(10, 2),
  declined BOOLEAN,
  product_ids VARCHAR(15) REFERENCES products(id), 
  user_id INT REFERENCES users(id),
  lat FLOAT,
  longitude FLOAT,
  FOREIGN KEY (business_id) REFERENCES companies(company_id), 
  FOREIGN KEY (card_id) REFERENCES credit_cards(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
 );


SHOW VARIABLES LIKE 'secure_file_priv'; -- buscar la ruta de secure-file-priv
-- copio los ficheros en la ruta

-- cargo los datos de la tabla companies

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"' -- esto sirve para cuando los valores de los campos estan entre comillas
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT *
FROM companies;

-- cargo los datos de la tabla credit_cards

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"' -- esto sirve para cuando los valores de los campos estan entre comillas
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT *
FROM credit_cards;


-- cargo los datos de la tabla users_usa,  en user

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_usa.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT *
FROM users;

-- cargo los datos de la tabla users_uk,  en user

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_uk.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- cargo los datos de la tabla users_ca,  en user

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_ca.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT *
FROM users;

-- cargo los datos de la tabla transactions

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT *
FROM transactions;



-- ----------EJERCICIO 1-------------------------------------------
-- Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.

SELECT name, surname, email
FROM users
WHERE id IN (SELECT user_id 
             FROM transactions
             GROUP BY user_id
             HAVING COUNT(id)>30)
ORDER BY name;             
			 
                                                   
# ----------EJERCICIO 2-------------------------------------------

# Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT company_name, iban, ROUND(AVG(amount),2)
FROM transactions
JOIN credit_cards ON card_id = credit_cards.id
JOIN companies ON business_id = companies.company_id
WHERE company_name = 'Donec Ltd'
GROUP BY iban; 


-- -------------------------------- NIVEL 2 ------------------------

-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:

-- Creo la tabla estat_targetes
  
    CREATE TABLE IF NOT EXISTS estat_targetes (
  card_id VARCHAR(15) PRIMARY KEY NOT NULL,
  estado VARCHAR(25)
  );
  
-- Genero los datos y los cargo en la tabla estat_targetes  
INSERT INTO estat_targetes (card_id, estado)  
WITH transacciones_tarjetas AS (
    SELECT card_id, declined,
		   ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS row_transacciones
    FROM transactions
)
SELECT card_id,
    CASE 
        WHEN SUM(declined) = 3 THEN 't_inactiva'
        ELSE 't_activa'
    END AS estado_tarjeta
FROM transacciones_tarjetas
WHERE row_transacciones <= 3
GROUP BY card_id;

SELECT *
FROM estat_targetes;

-- creo la relación de la tabla estat_targetes y credit_cards
ALTER TABLE estat_targetes
  ADD FOREIGN KEY (card_id) REFERENCES credit_cards(id);

--  ----------EJERCICIO 1-------------------------------------------
-- Quantes targetes estan actives?

SELECT COUNT(estado) AS tarjetas_activas
FROM estat_targetes
WHERE estado = 't_activa';


-- -------------------------------- NIVEL 3 ------------------------
-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

-- Creo la tabla products

    CREATE TABLE IF NOT EXISTS products (
  id VARCHAR(15) PRIMARY KEY NOT NULL,
  product_name VARCHAR(150),
  price VARCHAR(100),
  colour VARCHAR(100),
  weight FLOAT,
  warehouse_id VARCHAR(10)
);

-- cargo los datos de la tabla products

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"' -- esto sirve para cuando los valores de los campos estan entre comillas
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- SOLUCIÓN 1

-- Creo la tabla transactions_productos
CREATE TABLE IF NOT EXISTS transactions_products (
  id MEDIUMINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  transaction_id VARCHAR(255),
  product_id VARCHAR(15),
  FOREIGN KEY (transaction_id) REFERENCES transactions(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
  );


INSERT INTO transactions_products (transaction_id, product_id)
SELECT id,
  CAST(jt.product_id AS UNSIGNED) AS Product_id
FROM transactions 
JOIN
 JSON_TABLE(
    CONCAT('["', REPLACE(product_ids, ',', '","'), '"]'),
     '$[*]' COLUMNS (
	  product_id VARCHAR(15) PATH '$'
	)
) AS jt; 

SELECT *
FROM transactions_products;

-- SOLUCIÓN 2

CREATE TABLE IF NOT EXISTS transation_num_product (
  id VARCHAR(255),
  product_ids VARCHAR(255),
  num_product INT
  )
SELECT id, product_ids,
 LENGTH(product_ids) - LENGTH(REPLACE(product_ids,',',''))+1 AS num_product
FROM transactions;

SELECT *
FROM transation_num_product;

-- Creo la tabla temporal num_control 

CREATE TEMPORARY TABLE IF NOT EXISTS num_control 
SELECT DISTINCT(num_product) num
FROM transation_num_product
ORDER BY num ASC;

-- Muestro los datos de la nueva tabla de control
SELECT * 
FROM num_control;

-- Creo la tabla transactions_productos
CREATE TABLE IF NOT EXISTS transactions_products (
  transaction_id VARCHAR(255),
  product_id VARCHAR(15),
  FOREIGN KEY (transaction_id) REFERENCES transactions(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
  );
  
-- cargo los datos en la tabla transactions_products
INSERT INTO transactions_products
SELECT id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids,',',num),',',-1))
FROM transation_num_product
JOIN num_control ON num_product >= num;

SELECT * 
FROM transactions_products;

 -- ----------EJERCICIO 1-------------------------------------------

-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte

SELECT product_name, COUNT(product_id) AS cant_ventas_product, price, colour
FROM products
JOIN transactions_products ON products.id = transactions_products.product_id
JOIN transactions ON transactions.id = transactions_products.transaction_id
WHERE declined = 0
GROUP BY products.id 
ORDER BY cant_ventas_product DESC;
