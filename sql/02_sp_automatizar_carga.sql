-- =============================================================================
-- SCRIPT 02: PROCEDIMIENTO ALMACENADO ETL DE CARGA IDEMPOTENTE (MERGE / INSERT)
-- =============================================================================
USE DM_MINSA_VACUNACION;
GO
CREATE OR ALTER PROCEDURE dbo.sp_automatizar_carga_datamart
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        MERGE dbo.DIM_UBIGEO AS target
        USING (SELECT DISTINCT cod_ubigeo_inei, departamento, provincia, distrito, macroregion, poblacion_meta 
               FROM dbo.stg_catalogo_inei) AS source
        ON (target.cod_ubigeo_inei = source.cod_ubigeo_inei)
        WHEN MATCHED THEN
            UPDATE SET target.poblacion_meta = source.poblacion_meta
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (cod_ubigeo_inei, departamento, provincia, distrito, macroregion, poblacion_meta)
            VALUES (source.cod_ubigeo_inei, source.departamento, source.provincia, source.distrito, source.macroregion, source.poblacion_meta);

        ALTER INDEX CCI_FACT_VACUNACION ON dbo.FACT_VACUNACION REBUILD;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
