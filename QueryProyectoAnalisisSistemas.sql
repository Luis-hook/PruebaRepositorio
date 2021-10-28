USE master;

CREATE DATABASE ProyectoAnalisisSistemas2021;
GO

USE ProyectoAnalisisSistemas2021;
GO



ALTER DATABASE ProyectoAnalisisSistemas2021
ADD FILEGROUP FG_FileStream CONTAINS FILESTREAM;
GO

ALTER DATABASE ProyectoAnalisisSistemas2021
ADD FILEGROUP FG_Data;
GO

ALTER DATABASE ProyectoAnalisisSistemas2021 
ADD FILE ( NAME = N'Data', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLSERVER2019DEV\MSSQL\DATA\Data.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP FG_Data
GO

ALTER DATABASE ProyectoAnalisisSistemas2021
ADD FILE ( NAME = N'Archivos', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLSERVER2019DEV\MSSQL\DATA\Archivos' ) TO FILEGROUP [FG_FileStream]
GO

IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'FG_Data') ALTER DATABASE [ProyectoAnalisisSistemas2021] MODIFY FILEGROUP [FG_Data] DEFAULT
GO

CREATE TABLE CategoriaProducto
(
	CategoriaID INT NOT NULL IDENTITY(1,1),
	NombreCategoria NVARCHAR(50) NOT NULL,
	Descripcion NVARCHAR(70) NOT NULL
	CONSTRAINT PK_CategoriaProducto PRIMARY KEY(CategoriaID)
);
GO

CREATE TABLE Producto
(
  ID	UNIQUEIDENTIFIER ROWGUIDCOL	NOT NULL UNIQUE,
  ProductoID	INT			NOT NULL IDENTITY(1,1),
  Nombre		NVARCHAR(25)	NOT NULL,
  Descripcion	NVARCHAR(100)	NOT NULL,
  Precio		MONEY			NOT NULL,
  Disponible	BIT			NULL,
  Fotografia	VARBINARY(MAX) FILESTREAM,
  --CategoriaProductoID INT NOT NULL
  
  CONSTRAINT PK_Producto PRIMARY KEY(ProductoID)
  
) ON FG_Data;
GO

CREATE TABLE MecanismoContacto
(
MecanismoContactoID INT NOT NULL IDENTITY(1,1),
NumeroTelefono NVARCHAR(100) NOT NULL,
CorreoElectronico NVARCHAR(100) NOT NULL

)

CREATE TABLE Cliente
(
  ClienteID		BIGINT		NOT NULL IDENTITY (1,1),
  CorreoElectronico		NVARCHAR(100)	NOT NULL,
  NombreCompleto	NVARCHAR(50)	NOT NULL,
  DireccionFisica NVARCHAR(100)	NOT NULL,
  Contrasenna	NVARCHAR(25)	NOT NULL,

  CONSTRAINT PK_Cliente PRIMARY KEY(ClienteID) 
);
GO



CREATE TABLE Administrador
(
  AdministradorID	INT		NOT NULL IDENTITY (1,1),
  CorreoElectronico		NVARCHAR(100)	NOT NULL,
  Contrasenna	NVARCHAR(25)	NOT NULL,
  

  CONSTRAINT PK_Administrador PRIMARY KEY(AdministradorID)
  
);
GO



--*************************************************************************************************************
--*************************************************************************************************************
--*************************************************************************************************************
--*************************************************************************************************************
--Procedimientos
GO



CREATE OR ALTER PROC Agregar_Modificar_Producto
	@ProductoID INT,
	@Nombre NVARCHAR(50),
	@Descripcion NVARCHAR(100),
	@Precio MONEY,
	@Fotografia VARBINARY(MAX),
	@Disponible BIT
AS
BEGIN
	SET NOCOUNT ON;
	IF (SELECT ProductoID FROM Producto WHERE ProductoID = @ProductoID) IS NULL
		INSERT INTO dbo.Producto
			 (ID, 
			  Nombre,
			  Descripcion,
			  Precio,
			  Fotografia,
			  Disponible)
		SELECT NEWID(),
			 @Nombre,
			 @Descripcion,
			 @Precio,		 
			 @Fotografia,
			 @Disponible
	ELSE
		UPDATE dbo.Producto SET
			Nombre = @Nombre,
			Descripcion = @Descripcion,	
			Precio = @Precio,
			Fotografia = @Fotografia,
			Disponible = @Disponible
		WHERE ProductoID = @ProductoID;
	SET NOCOUNT OFF
END;
GO

CREATE OR ALTER PROC ConsultarProductoPorNombre(@Nombre NVARCHAR(300))
AS
BEGIN
	SELECT P.ID,
		 P.ProductoID,
		 P.Descripcion,
		 P.Nombre,
		 P.Precio,
		 P.Fotografia,
		 P.Disponible
	FROM dbo.Producto AS P
	WHERE CAST(Nombre AS NVARCHAR) Like CAST(@Nombre AS NVARCHAR) + '%'	
		OR Nombre = @Nombre
END;
GO
--CREATE OR ALTER PROC ConsultarProductoPorCategoria(@CategoriaProducto NVARCHAR(100))
--AS
--BEGIN
--	SELECT P.ID,
--		 P.ProductoID,
--		 P.Descripcion,
--		 P.Nombre,
--		 P.Precio,
--		 P.Fotografia,
--		 P.Disponible,
--		 P.CategoriaProducto
--	FROM dbo.Producto AS P
--	WHERE CAST(CategoriaProducto AS NVARCHAR) Like CAST(@CategoriaProducto AS NVARCHAR) + '%'	
--		OR CategoriaProducto = @CategoriaProducto
--END;
GO



CREATE OR ALTER PROC EliminarProducto
	@ProductoID INT
AS	
BEGIN
	--DELETE PPP
	--FROM PlatilloPorPedido AS PPP
	--WHERE PlatilloID = @PlatilloID
	DELETE P
	FROM Producto AS P
	WHERE ProductoID = @ProductoID
END;
GO

CREATE OR ALTER PROC Agregar_Modificar_Administradores
	@AdministradorID BIGINT,
	@CorreoElectronico NVARCHAR(50),
	@Contrasenna NVARCHAR(25) 
AS
BEGIN
	SET NOCOUNT ON;
IF (SELECT AdministradorID FROM Administrador WHERE AdministradorID = @AdministradorID) IS NULL
	INSERT INTO dbo.Administrador
		 (CorreoElectronico,
		  Contrasenna)
	VALUES
		(@CorreoElectronico,
		 @Contrasenna)
ELSE
     UPDATE dbo.Administrador SET
		  CorreoElectronico = @CorreoElectronico,
		  Contrasenna = @Contrasenna
	 WHERE AdministradorID = @AdministradorID
SET NOCOUNT OFF
  END;
GO

CREATE OR ALTER PROC Agregar_Modificar_Cliente
	@ClienteID BIGINT,
	@CorreoElectronico NVARCHAR(50),
	@NombreCompleto NVARCHAR(50),
	@DireccionFisica NVARCHAR(100),
	@Contrasenna NVARCHAR(25)
AS
BEGIN
	SET NOCOUNT ON;
IF NOT EXISTS (SELECT ClienteID FROM Cliente WHERE ClienteID = @ClienteID)
	INSERT INTO dbo.Cliente
		 (CorreoElectronico, 
		 NombreCompleto, 
		 DireccionFisica, 
		 Contrasenna)
	VALUES
		(@CorreoElectronico, 
		 @NombreCompleto, 
		 @DireccionFisica, 
		 @Contrasenna)
ELSE
     UPDATE dbo.Cliente SET
		  CorreoElectronico = @CorreoElectronico,
		  NombreCompleto = @NombreCompleto,
		  DireccionFisica = @DireccionFisica,
		  Contrasenna = @Contrasenna
	 WHERE ClienteID = @ClienteID
SET NOCOUNT OFF
  END;
GO

CREATE OR ALTER PROC VerificarCorreoExiste(@Correo NVARCHAR(50))
AS
BEGIN
	--DECLARE @CorreoEncontrado AS NVARCHAR(50)
	--SET @CorreoEncontrado = (SELECT CorreoElectronico
	--FROM Usuario
	--WHERE CorreoElectronico = @Correo)
	--IF(@CorreoEncontrado IS NULL)
	--	SET @CorreoEncontrado = (SELECT CorreoElectronico
	--	FROM Cliente
	--	WHERE CorreoElectronico = @Correo)
	--SELECT @CorreoEncontrado AS CorreoEncontrado
	SELECT CorreoElectronico
	FROM Administrador
	WHERE CorreoElectronico = @Correo
END;
GO



CREATE OR ALTER PROC EliminarAdministrador
	@AdministradorID INT
AS	
BEGIN
	DELETE A
	FROM Administrador AS A
	WHERE AdministradorID = @AdministradorID
END;

GO


GO



CREATE OR ALTER PROC ProductosDisponibles
AS
	BEGIN		
		SELECT ProductoID
			, Nombre
			, Descripcion
			, Precio
			, Disponible
			, Fotografia
		FROM Producto
		WHERE Disponible = 1
	END;
GO



CREATE OR ALTER PROC VerificarAdministradorExiste (@CorreoElectronico NVARCHAR(50)
	, @Contrasenna NVARCHAR(25))
AS
	BEGIN
		SELECT AdministradorID
			,CorreoElectronico
			,Contrasenna
		FROM Administrador
		WHERE CorreoElectronico = @CorreoElectronico
			AND Contrasenna = @Contrasenna
	END;
GO

CREATE OR ALTER PROC VerificarClienteExiste (
	@CorreoElectronico NVARCHAR(50)
	, @Contrasenna NVARCHAR(25))	
AS
	BEGIN
		SELECT ClienteID
			,CorreoElectronico
			,NombreCompleto
			,DireccionFisica
			,Contrasenna
		FROM Cliente
		WHERE CorreoElectronico = @CorreoElectronico
			AND Contrasenna = @Contrasenna			
	END;
GO

CREATE OR ALTER PROC HabilitarDeshabilitarProducto
	@ProductoID INT,
	@Disponible BIT
AS
BEGIN
	UPDATE dbo.Producto
	SET Disponible = @Disponible
	WHERE ProductoID = @ProductoID
END;
GO



CREATE OR ALTER PROC ObtenerProductos
AS
BEGIN
	SELECT ID
		,ProductoID
		,Nombre
		,Descripcion
		,Precio
		,Disponible
		,Fotografia
	FROM Producto;
END;
GO

CREATE OR ALTER PROC ObtenerAdministradores
AS
BEGIN
	SELECT AdministradorID
		,CorreoElectronico
		,Contrasenna
	FROM Administrador;
END;
GO


CREATE OR ALTER PROC ObtenerClientes
AS 
BEGIN 
SELECT ClienteID
     , CorreoElectronico
	 , NombreCompleto
	 , DireccionFisica
	 , Contrasenna
FROM Cliente;
END;

