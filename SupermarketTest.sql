--Crear una base de datos de ejemplo para un sistema de supermercado
-- Autor: Francis Fulgencio Fecha: 12/04/2019

CREATE DATABASE SUPERMARKET
GO
USE SUPERMARKET
GO
-- DATOS DOCUMENTOS
-- Creé esta tabla para catalogar los tipos de documentos como facturas a credito o ordenes de compra al contado, por ejemplo.
CREATE TABLE DOCUMENTOS(
	 documentoId		char(2)			primary key
	,nombre				varchar(50)		not null
);
-- DATOS DE PROVINCIAS
-- Par normalizar y optimizar el rendimiento y eficientizar el consumo de almacenamiento
CREATE TABLE PROVINCIAS(
	 provinciaId		tinyint				identity(1,1) primary Key
	,nombre				varchar(50)		not null
);

-- DATOS DE SECTOR
-- Par normalizar y optimizar el rendimiento y eficientizar el consumo de almacenamiento
CREATE TABLE SECTOR(
	 sectorId		tinyint				identity(1,1) primary Key
	,nombre			varchar(50)		NOT NULL
	,provinciaId	tinyint
	,constraint FK_sector_provincias
		foreign key (provinciaId) references provincias(provinciaId)			
);

-- DATOS DE SUCURSALES
CREATE TABLE SUCURSALES(
	sucursalId		tinyint			identity(1,1) primary key
	,nombre			varchar(50)		not null
	,telefono		char(13)		null
	,direccion		varchar(50)		null
	,sectorId		tinyint
	,provinciaId	tinyint
	,constraint FK_sucursales_sector
		foreign key (sectorId) references Sector(sectorId)
	,constraint FK_sucursales_provincias 
		foreign key (sectorId) references Provincias(provinciaId)
);

-- DATOS DE CLIENTES
CREATE TABLE CLIENTES(
	 clienteId		int				identity(1,1) primary key
	,nombre			varchar(50)		not null
	,apellido1		varchar(20)		not null
	,apellido2		varchar(20)		null
	,cedula			char(11)		unique
	,sucursalId		tinyint			-- para establecer sucursal de origen, no limita compras.
	,telefono1		char(13)		null
	,telefono2		char(13)		null
	,direccion		varchar(100)	null
	,sectorId		tinyint
	,provinciaId	tinyint
	,constraint FK_clientes_sucursales 
		foreign key (sucursalId)	references sucursales(sucursalId)
	,constraint FK_clientes_sector 
		foreign key (sectorId)		references Sector(sectorId)
	,constraint FK_clientes_provincias 
		foreign key (provinciaId) references Provincias(provinciaId)
);


--DATOS DE CATEGORIAS
CREATE TABLE CATEGORIAS(
	categoriaId		smallint		identity(1,1) primary key
	,nombre			varchar(50)		not null,
);

--DATOS DE ARTICULOS
CREATE TABLE ARTICULOS(
	articuloId		int				identity(1,1) primary key
	,estado			char(1)			default 'A' -- se puede catalogar
	,nombre			varchar(50)		not null
	,categoriaId	smallint			
	,aplicaItbis	bit				default 1   --- 0 = false 1 = true
	,unidadMayor	char(1)			null   -- se puede catalogar U = unidad A = ampolla C = Caja
	,unidadDetalle	char(1)			null   -- se puede catalogar U = unidad A = ampolla C = Caja
	,factor			smallint		null
	,ultimoCosto	decimal(10,2)   default 0
	,precio			decimal(10,2)	null
	,stockMin		decimal(10,2)	null
	,stockMax		decimal(10,2)	null
	,vencimiento	date			null
	constraint FK_articulos_categorias 
		foreign key (categoriaId) references Categorias(categoriaId)
);

--DATOS DE SUPLIDORES

CREATE TABLE SUPLIDORES(
	suplidorId		int				identity(1,1) primary key
	,nombre			varchar(100)	not null
	,rnc			char(11)		unique
	,telefono		char(13)		null 
	,direccion		varchar(50)		null
	,sectorId		tinyint
	,provinciaId	tinyint
	,constraint FK_suplidores_sector
		foreign key (sectorId) references Sector(sectorId)
	,constraint FK_suplidores_provincias 
		foreign key (provinciaId) references Provincias(provinciaId)
);

--DATOS DE CARGOS
CREATE TABLE CARGOS(
	cargoId			tinyint				identity(1,1) primary key,
	nombre			varchar(15)		not null
);
-- DATOS DE EMPLEADOS
CREATE TABLE EMPLEADOS(
	 empleadoId		smallint		identity(1,1) primary key
	,estado			char(1)			default 'A' --se puede categorizar A= Activo V = vacaciones C = cancelado etc
	,nombre			varchar(50)		not null
	,apellido1		varchar(20)		not null
	,apellido2		varchar(20)		null
	,cedula			char(11)		unique
	,fechaNac		date
	,fechaContrato	date
	,sucursalId		tinyint
	,superiorId		int
	,cargoId		tinyint
	,telefono1		char(13)		null
	,telefono2		char(13)		null
	,direccion		varchar(100)	null
	,sectorId		tinyint
	,provinciaId	tinyint
	,constraint FK_empleado_cargos
		foreign key (cargoId) references Cargos(cargoId)
	,constraint FK_empleado_sucursales
		foreign key (sucursalId) references Sucursales(sucursalId)
	,constraint FK_empleado_sector 
		foreign key (sectorId) references Sector(sectorId)
	,constraint FK_empleado_provincias 
		foreign key (provinciaId) references Provincias(provinciaId)
);
--- DATOS DE ORDENES DE COMPRA
CREATE TABLE ORDENES(
	ordenId			int				identity(1,1) primary key
	,sucursalId		tinyint			
	,documentoId	char(2)			not null
	,estado			char(1)			default 'A'  --Se puede catalogar
	,suplidorId		int
	,fecha			date
	,itbis			decimal(10,2)
	,total			decimal(14,2)
	,empleadoId		smallint				
	,fechaRegistro	datetime		default getdate()
	,lastUpdate		datetime		default getdate()
	,constraint	FK_ordenes_Sucursales
		foreign key (sucursalId) references Sucursales(sucursalId)
	,constraint FK_ordenes_documentos
		foreign key	(documentoId) references Documentos(documentoId)
	,constraint FK_ordenes_suplidores
		foreign key (suplidorId) references Suplidores(suplidorId)
	, constraint fk_ordenes_empleados
		foreign key (empleadoId) references Empleados(empleadoId)
);

CREATE TABLE ORDENESDT(
	ordenId			int
	,secuencia		int
	,articuloId		int
	,cantidad		decimal(10,2)
	,precioUnitario	decimal(10,2)
	,subtotal		as cantidad * precioUnitario
	,itbis			as (subtotal * 0.18)
	,constraint fk_ordenes_articulos
		foreign key (articuloId) references Articulos(articuloId)
	,constraint fk_ordenes_ordenesdt
		foreign key (ordenId) references Ordenes(ordenId)
)

--- DATOS DE FACTURAS
CREATE TABLE FACTURAS(
	facturaId		int				identity(1,1) primary key
	,sucursalId		tinyint
	,documentoId	char(2)
	,estado			char(1)			default 'A'  --se puede catalogar Ej. A = Activa C = Anulada 
	,clienteId		int
	,fecha			date
	,itbis			decimal(10,2)
	,total			decimal(14,2)
	,empleadoId		smallint
	,fechaRegistro	datetime		default getdate()
	,lastUpdate		datetime		default getdate()
	,constraint FK_factura_sucursales
		foreign key (sucursalId) references Sucursales(sucursalId)
	,constraint FK_facturas_documentos
		foreign key	(documentoId) references Documentos(documentoId)
	,constraint FK_FACTURAS_suplidores
		foreign key (clienteId) references Clientes(clienteId)
	, constraint fk_facturas_empleados
		foreign key (empleadoId) references Empleados(empleadoId)
);

CREATE TABLE FACTURADT(
	 facturaId		int
	,secuencia		int
	,articuloId		int
	,cantidad		decimal(10,2)
	,precioUnitario	decimal(10,2)
	,subtotal		as (cantidad * precioUnitario)
	,itbis			as (cantidad * 0.18)
	,constraint fk_facturasdt_articulos
		foreign key (articuloId) references Articulos(articuloId)
	,constraint fk_facturasdt_facturas
		foreign key (facturaId) references Facturas(facturaId)
);

-- HISTORIAL DE CAMBIOS EN LA FACTURA

CREATE TABLE AUDITFACTURAS(
	 secuencia		int				--secuencia para las modificaciones
	,facturaId		int				
	,sucursalId		tinyint
	,documentoId	char(2)
	,estado			char(1)		
	,clienteId		int
	,fecha			date
	,itbis			decimal(10,2)
	,total			decimal(14,2)
	,empleadoId		smallint
	,fechaRegistro	datetime		default getdate()
	,lastUpdate		datetime
	,Tipo			VARCHAR(15)    --Anterior | nuevo
	,fechaAudit		datetime

);

GO
--Crea una funcion que calcule el itbis de cada articulo.
CREATE FUNCTION dbo.fCalcularItebis
(
	@valorArticulo decimal(10,2),
	@porcentage	   decimal(10,2)
)
RETURNS decimal(10,2)
AS
BEGIN

    RETURN (@valorArticulo * @porcentage ) / 100

END


go


--select dbo.[FunctionName](115,18)

--Crear stored procedure que cancele una factura.
go
create procedure spCancelarFactura(
	@facturaId int
)as
BEGIN
	if exists (select facturaId from Facturas where facturaId = @facturaId)
	begin
		update facturas
		set estado = 1
		where facturaId = @facturaId
	end

END
go

--Crear trigger que guarde los cambios en un factura dada.


create TRIGGER tguardarAuditoria
    ON dbo.FACTURAS
    FOR  UPDATE
    AS
    BEGIN
		SET NOCOUNT ON
		declare @id int =(select max(secuencia) from AUDITFACTURAS) ;
		
		IF @id is null
			set @id = 1 

		INSERT INTO AUDITFACTURAS
			select @id,d.*,'Anterior', getdate() 
				from deleted d
		INSERT INTO AUDITFACTURAS
			select @id,i.*,'Nuevo',getdate() 
				from inserted i
    END

/*
	use master
	go
	drop database supermarket

*/

