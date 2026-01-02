# Online Retail Analytics: De Datos Sucios a Insights de Negocio

Este proyecto es una solución completa de análisis de datos (End-to-End) para un dataset transaccional de ventas minoristas. El objetivo fue auditar la calidad de los datos, construir un flujo de limpieza automatizado y diseñar un modelo de datos robusto para la toma de decisiones.

# Problemática

Este proyecto pretende ser un primer análisis del estado de las ventas de un negocio minorista, el cual quiere responder las siguientes incógnitas:

* ** Si realizamos un análisis competitivo y de pricing, ¿En qué países debiéramos enfocarnos? ¿Qué horarios de venta son los más competitivos? ¿En qué épocas del año nos ha ido mejor?
* ** ¿Cuáles son nuestros productos más redituables? ¿Qué productos debiéramos sacar de nuestro catálogo?

## Tech Stack

* **Análisis Exploratorio:** Microsoft Excel.
* **Procesamiento ETL:** Python (Pandas, NumPy).
* **Base de Datos & Modelado:** PostgreSQL (SQLAlchemy).
* **Visualización:** Power BI.

---

##  1. El Problema: Auditoría de Calidad (EDA)

Antes de escribir código, realicé una auditoría manual de los datos crudos utilizando Excel. Identifiqué tres problemas críticos que distorsionaban la realidad del negocio:

### A. Precios Inconsistentes
Se detectaron transacciones con `UnitPrice = 0`, lo cual indicaba errores de sistema o regalos no documentados que afectarían el cálculo de ingresos.

### B. Devoluciones Mezcladas
La columna de cantidad (`Quantity`) contenía valores negativos masivos (ej. -80,995). Esto indicaba devoluciones, no errores de digitación.

### C. Datos Sucios
La columna de descripción contenía ruido, valores nulos y caracteres extraños (`?`, `?? missing`).

---

##  2. La Solución: Ingeniería de Datos (Python)

Basado en los hallazgos anteriores, desarrollé un pipeline en Python (`OnlineRetailDataset.ipynb`) para sanear los datos:

**Lógica de Negocio aplicada:**
En lugar de eliminar las cantidades negativas (pérdida de información), creé una lógica para separarlas y analizar las devoluciones.

```python
# Separación inteligente de ventas y devoluciones
df['refunds'] = np.where(df['Quantity'] < 0, df['Quantity'], 0)
df['Quantity'] = np.where(df['Quantity'] < 0, 0, df['Quantity'])

# Eliminación de ruido mediante Expresiones Regulares (Regex)
df['Description'] = (
    df['Description']
    .str.strip()
    .replace(r'^\?+$', np.nan, regex=True) # Elimina '?' o '??'
    .fillna("Unknown")
)
```

---

##  3.  Modelado Avanzado en SQL

Transformé un archivo plano (CSV) en un Esquema Relacional (Estrella) optimizado, dividiendo los datos en tablas de Hechos (orders, order_details) y Dimensiones (products, customers).

Uno de los mayores retos fue asegurar que la dimensión de clientes (dim_customers) fuera única, ya que existían clientes que realizaron compras desde dos países distintos. Utilicé funciones de ventana en SQL para eliminar duplicados directamente en la base de datos:

```SQL
/* Elimina duplicados manteniendo solo el registro único usando CTID */
DELETE FROM dim_customers
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid, ROW_NUMBER() OVER (PARTITION BY customer_id) AS rn
        FROM dim_customers
    ) t
    WHERE rn > 1
);
```

---

##  4.  Resultados (Power BI)

El Dashboard final (Dashboard.pbix) consume el modelo limpio y responde preguntas clave:

<img width="1416" height="765" alt="imagen" src="https://github.com/user-attachments/assets/dfc083eb-200d-42d2-9822-c23bdc43dd80" />


    Análisis de productos: Identificación de productos con mayores cantidades vendidas netas y los productos con más devoluciones.

    Patrones de Compra: Análisis temporal ajustable por filtros; hora, día, mes, trimestre, año, como también por país.
    
---

##  5. Cómo ejecutar este proyecto

    1. Clonar el repositorio.

    2. Instalar dependencias: pip install pandas sqlalchemy psycopg2-binary.

    3. Configurar la conexión a PostgreSQL en el script de Python.

    4. Ejecutar el notebook para realizar la carga y transformación.

    5. Abrir el archivo .pbix en Power BI.
    
---
