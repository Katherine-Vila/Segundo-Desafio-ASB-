CREATE DATABASE SuperAhorro;
GO
USE SuperAhorro;
GO

-- =========================
-- TABLAS
-- =========================

-- Tabla Categoria
CREATE TABLE Categoria (
    CategoriaID CHAR(5) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL UNIQUE
);

-- Tabla Proveedor
CREATE TABLE Proveedor (
    ProveedorID CHAR(5) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Telefono VARCHAR(15),
    Direccion VARCHAR(150),
    CONSTRAINT UQ_Proveedor_Nombre UNIQUE(Nombre)
);

-- Tabla Producto
CREATE TABLE Producto (
    ProductoID CHAR(5) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Precio DECIMAL(10,2) CHECK (Precio > 0),
    Stock INT DEFAULT 0 CHECK (Stock >= 0),
    CategoriaID CHAR(5) NOT NULL,
    ProveedorID CHAR(5) NOT NULL,
    FOREIGN KEY (CategoriaID) REFERENCES Categoria(CategoriaID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ProveedorID) REFERENCES Proveedor(ProveedorID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla Cliente
CREATE TABLE Cliente (
    ClienteID CHAR(5) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Telefono VARCHAR(15)
);

-- Tabla Empleado
CREATE TABLE Empleado (
    EmpleadoID CHAR(5) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Cargo VARCHAR(50),
    Salario DECIMAL(10,2) CHECK (Salario >= 0)
);

-- Tabla Venta
CREATE TABLE Venta (
    VentaID CHAR(5) PRIMARY KEY,
    Fecha DATE DEFAULT GETDATE(),
    ClienteID CHAR(5) NOT NULL,
    EmpleadoID CHAR(5) NOT NULL,
    Total DECIMAL(12,2) CHECK (Total >= 0),
    FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (EmpleadoID) REFERENCES Empleado(EmpleadoID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla DetalleVenta
CREATE TABLE DetalleVenta (
    VentaID CHAR(5),
    ProductoID CHAR(5),
    Cantidad INT CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(10,2) CHECK (PrecioUnitario > 0),
    Subtotal DECIMAL(12,2) CHECK (Subtotal >= 0),
    PRIMARY KEY (VentaID, ProductoID),
    FOREIGN KEY (VentaID) REFERENCES Venta(VentaID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ProductoID) REFERENCES Producto(ProductoID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =========================
-- DATOS
-- =========================

INSERT INTO Categoria VALUES
('CAT01', 'Lácteos'),
('CAT02', 'Bebidas'),
('CAT03', 'Aseo');

INSERT INTO Proveedor VALUES
('PROV1', 'Nestlé', '2222-1111', 'San Salvador'),
('PROV2', 'Coca-Cola', '2222-2222', 'Santa Tecla'),
('PROV3', 'Unilever', '2222-3333', 'Soyapango');

INSERT INTO Producto VALUES
('PROD1', 'Leche Entera', 1.20, 50, 'CAT01', 'PROV1'),
('PROD2', 'Yogurt Natural', 0.90, 30, 'CAT01', 'PROV1'),
('PROD3', 'Coca-Cola 1L', 1.50, 100, 'CAT02', 'PROV2'),
('PROD4', 'Jabón Dove', 0.80, 15, 'CAT03', 'PROV3');

INSERT INTO Cliente VALUES
('CLI01', 'Ana', 'Lopez', 'ana@email.com', '7000-1111'),
('CLI02', 'Luis', 'Martinez', 'luis@email.com', '7000-2222');

INSERT INTO Empleado VALUES
('EMP01', 'Carlos', 'Perez', 'Cajero', 500.00),
('EMP02', 'Marta', 'Gomez', 'Vendedor', 600.00);

-- NOTA: los totales en la tabla Venta están calculados a partir de los subtotales de DetalleVenta
INSERT INTO Venta VALUES
('VENT1', '2025-04-05', 'CLI01', 'EMP01', 5.60), -- 2.40 + 0.90 + 1.50 + 0.80 = 5.60
('VENT2', '2025-04-15', 'CLI02', 'EMP02', 2.60); -- 1.80 + 0.80 = 2.60

-- DetalleVenta: precios y subtotales coherentes con Producto.Precio
INSERT INTO DetalleVenta VALUES
('VENT1', 'PROD1', 2, 1.20, 2.40), -- leche
('VENT1', 'PROD2', 1, 0.90, 0.90), -- yogurt
('VENT1', 'PROD3', 1, 1.50, 1.50), -- coca
('VENT1', 'PROD4', 1, 0.80, 0.80), -- jabón  => CLI01 compró 4 productos distintos
('VENT2', 'PROD2', 2, 0.90, 1.80), -- yogurt
('VENT2', 'PROD4', 1, 0.80, 0.80); -- jabón

-- =========================
-- CONSULTAS CORREGIDAS / RECOMENDADAS
-- =========================

-- 1) Listar todos los productos con su categoría y proveedor
SELECT P.ProductoID, P.Nombre AS Producto, C.Nombre AS Categoria, PR.Nombre AS Proveedor
FROM Producto P
JOIN Categoria C ON P.CategoriaID = C.CategoriaID
JOIN Proveedor PR ON P.ProveedorID = PR.ProveedorID;

-- 2) Mostrar las ventas realizadas por el empleado con ID 'EMP01'
SELECT * FROM Venta
WHERE EmpleadoID = 'EMP01';

-- 3) Contar cuántos productos hay por categoría
SELECT C.Nombre AS Categoria, COUNT(P.ProductoID) AS CantidadProductos
FROM Categoria C
LEFT JOIN Producto P ON C.CategoriaID = P.CategoriaID
GROUP BY C.Nombre;

-- 4) Listar clientes que han comprado más de 3 productos diferentes
--  (Si tu comentario dice "más de 3", el operador correcto es > 3)
SELECT V.ClienteID, COUNT(DISTINCT D.ProductoID) AS ProductosDiferentes
FROM Venta V
JOIN DetalleVenta D ON V.VentaID = D.VentaID
GROUP BY V.ClienteID
HAVING COUNT(DISTINCT D.ProductoID) > 3;
-- Con los datos de ejemplo, CLI01 cumple (compró 4 productos distintos).

-- 4b) Si lo que quieres es "al menos 3" (>=3)
SELECT V.ClienteID, COUNT(DISTINCT D.ProductoID) AS ProductosDiferentes
FROM Venta V
JOIN DetalleVenta D ON V.VentaID = D.VentaID
GROUP BY V.ClienteID
HAVING COUNT(DISTINCT D.ProductoID) >= 3;

-- 5. Mostrar el producto más vendido (en cantidad)
SELECT TOP 1 P.ProductoID, P.Nombre, SUM(D.Cantidad) AS TotalVendido
FROM DetalleVenta D
JOIN Producto P ON D.ProductoID = P.ProductoID
GROUP BY P.ProductoID, P.Nombre
ORDER BY TotalVendido DESC;

-- 6) Calcular el total de ventas del mes de abril de 2025 (sumando subtotales reales)
SELECT SUM(D.Subtotal) AS TotalAbril2025
FROM Venta V
JOIN DetalleVenta D ON V.VentaID = D.VentaID
WHERE MONTH(V.Fecha) = 4 AND YEAR(V.Fecha) = 2025;

-- 7) Listar proveedores que suministran más de 2 productos
SELECT PR.Nombre, COUNT(P.ProductoID) AS ProductosSuministrados
FROM Proveedor PR
JOIN Producto P ON PR.ProveedorID = P.ProveedorID
GROUP BY PR.Nombre
HAVING COUNT(P.ProductoID) >= 2;


-- 8) Actualizar el stock del producto 'PROD1' restando 5 unidades (con control para no quedar negativo)
UPDATE Producto
SET Stock = Stock - 5
WHERE ProductoID = 'PROD1' AND Stock >= 5;

-- 9) Mostrar el cliente que más ha gastado en total (calculado desde DetalleVenta para evitar inconsistencias)
SELECT TOP 1 C.ClienteID, C.Nombre, C.Apellido, SUM(D.Subtotal) AS GastoTotal
FROM Cliente C
JOIN Venta V ON C.ClienteID = V.ClienteID
JOIN DetalleVenta D ON V.VentaID = D.VentaID
GROUP BY C.ClienteID, C.Nombre, C.Apellido
ORDER BY GastoTotal DESC;

-- 10) Listar productos con stock menor a 10 unidades
SELECT ProductoID, Nombre, Stock
FROM Producto
WHERE Stock <= 30;


-- Ver todo el detalle de ventas
SELECT * FROM DetalleVenta;
