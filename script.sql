-- EN SQL --

-- Elimino tabla dim_customers si existe

DROP TABLE IF EXISTS dim_customers CASCADE;

-- Creo tabla dim_customers

CREATE TABLE dim_customers AS 
TABLE customers;

-- Creo tabla Dim_customers sin duplicados

DELETE FROM dim_customers -- Esta tabla va a tener valores id únicos, customers va a tener ID's duplicados.
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid,
               ROW_NUMBER() OVER (
                   PARTITION BY customer_id
               ) AS rn
        FROM dim_customers
    ) t
    WHERE rn > 1
);

	-- ARREGLO ALGUNOS TIPOS DE DATOS

ALTER TABLE dim_customers
ALTER COLUMN customer_id TYPE INT;

ALTER TABLE orders
ALTER COLUMN customer_id TYPE INT;

-- creo PKs en cada tabla

  -- dim_customers


    ALTER TABLE dim_customers
    ADD CONSTRAINT pk_dim_customers 
    PRIMARY KEY (customer_id); -- customer_id queda como clave principal


  -- order_details

    ALTER TABLE order_details
    ADD COLUMN order_detail_id BIGSERIAL;

    ALTER TABLE order_details
    ADD CONSTRAINT pk_order_details
    PRIMARY KEY (order_detail_id);

    ALTER TABLE order_details
    ALTER COLUMN order_detail_id SET NOT NULL;

    -- products

    ALTER TABLE products
    ADD CONSTRAINT product_id
    PRIMARY KEY (product_id);

    -- orders
    ALTER TABLE orders
    ADD CONSTRAINT order_id
    PRIMARY KEY(order_id);

-- Creo FK en tablas

    -- order_details
    ALTER TABLE order_details
    ADD CONSTRAINT product_id
    FOREIGN KEY (product_id)
    REFERENCES products;

    ALTER TABLE order_details
    ADD CONSTRAINT order_id
    FOREIGN KEY (order_id)
    REFERENCES orders;

    -- orders
    ALTER TABLE orders
    ADD CONSTRAINT customer_id
    FOREIGN KEY (customer_id)
    REFERENCES dim_customers;


--  Creo columna de hora para análisis detallado
ALTER TABLE orders
ADD COLUMN InvoiceDate_Hour TIME;

-- Relleno la columna de hora desde InvoiceDate
UPDATE orders
SET InvoiceDate_Hour = "InvoiceDate"::time;

-- Convierto InvoiceDate a solo FECHA (año-mes-día)
ALTER TABLE orders
ALTER COLUMN "InvoiceDate" TYPE DATE
USING "InvoiceDate"::date;



