-- =============================================================================
-- SCRIPT 01: CREACION DEL DATA MART EN ESTRELLA E INDICES COLUMNSTORE
-- Motor: Microsoft SQL Server 2022 Developer Edition
-- =============================================================================
USE master;
GO
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'DM_MINSA_VACUNACION')
    CREATE DATABASE DM_MINSA_VACUNACION;
GO
USE DM_MINSA_VACUNACION;
GO

CREATE TABLE dbo.DIM_TIEMPO (
    id_tiempo INT PRIMARY KEY,
    fecha DATE NOT NULL,
    anio SMALLINT NOT NULL,
    trimestre SMALLINT NOT NULL,
    mes_num SMALLINT NOT NULL,
    mes_nombre VARCHAR(20) NOT NULL,
    semana_epidemiol INT NOT NULL
);

CREATE TABLE dbo.DIM_UBIGEO (
    id_ubigeo INT IDENTITY(1,1) PRIMARY KEY,
    cod_ubigeo_inei CHAR(6) NOT NULL UNIQUE,
    departamento VARCHAR(60) NOT NULL,
    provincia VARCHAR(80) NOT NULL,
    distrito VARCHAR(100) NOT NULL,
    macroregion VARCHAR(40) NOT NULL,
    poblacion_meta INT NOT NULL
);

CREATE TABLE dbo.DIM_ESTABLECIMIENTO (
    id_establecimiento INT IDENTITY(1,1) PRIMARY KEY,
    cod_renipress VARCHAR(12) NOT NULL UNIQUE,
    nombre_ipress VARCHAR(150) NOT NULL,
    institucion VARCHAR(60) NOT NULL,
    categoria_nivel CHAR(10) NOT NULL,
    diresa_geresa VARCHAR(80) NOT NULL
);

CREATE TABLE dbo.DIM_VACUNA (
    id_vacuna INT IDENTITY(1,1) PRIMARY KEY,
    cod_biologico VARCHAR(20) NOT NULL UNIQUE,
    fabricante VARCHAR(60) NOT NULL,
    nombre_vacuna VARCHAR(80) NOT NULL,
    esquema_max_dosis INT NOT NULL
);

CREATE TABLE dbo.DIM_GRUPO_ETARIO (
    id_grupo_etario INT IDENTITY(1,1) PRIMARY KEY,
    rango_edad VARCHAR(25) NOT NULL UNIQUE,
    etapa_vida_minsa VARCHAR(40) NOT NULL,
    grupo_riesgo BIT NOT NULL
);

CREATE TABLE dbo.FACT_VACUNACION (
    id_tiempo INT NOT NULL REFERENCES dbo.DIM_TIEMPO(id_tiempo),
    id_ubigeo INT NOT NULL REFERENCES dbo.DIM_UBIGEO(id_ubigeo),
    id_establecimiento INT NOT NULL REFERENCES dbo.DIM_ESTABLECIMIENTO(id_establecimiento),
    id_vacuna INT NOT NULL REFERENCES dbo.DIM_VACUNA(id_vacuna),
    id_grupo_etario INT NOT NULL REFERENCES dbo.DIM_GRUPO_ETARIO(id_grupo_etario),
    num_dosis SMALLINT NOT NULL,
    cant_aplicaciones INT NOT NULL,
    cant_hombres INT NOT NULL,
    cant_mujeres INT NOT NULL,
    fecha_carga_audit DATETIME2 DEFAULT SYSDATETIME()
);
GO
CREATE CLUSTERED COLUMNSTORE INDEX CCI_FACT_VACUNACION ON dbo.FACT_VACUNACION;
GO
