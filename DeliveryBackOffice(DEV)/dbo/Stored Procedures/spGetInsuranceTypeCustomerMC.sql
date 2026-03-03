/* =================================================
   SP:        [dbo].[spGetInsuranceTypeCustomerMC]
   Propósito: <Calculo del monto mínimo para asegurar un paquete en Express Center>
   Autor:     <Walter Orozco>
   Historia:  <FDAPI-2388>
   Fecha:     2024-07-05
============================================
=== CHANGELOG ================================
-- 2026-02-16 | Historia/épica: FDAPI-5351 | Autor: Cristian Azurdia |
-- 2024-07-19 | Historia/épica: FDAPI-2737 | Autor: Walter Orozco |
=========================================== */

ALTER PROCEDURE [dbo].[spGetInsuranceTypeCustomerMC]
    @pTypeCustomer INT,
    @pId INT,
    @pIdCountry NVARCHAR(2) = 'GT'
AS
BEGIN

    DECLARE @TypeCustomer INT;
    DECLARE @INSURANCEEXC TABLE
    (
         Insuranceid INT IDENTITY(1,1) PRIMARY KEY
        ,InsuranceRate   DECIMAL(12,2)
        ,InsuranceCharge DECIMAL(12,2)
        ,InsuranceExempt DECIMAL(12,2)
        ,CollectRate      DECIMAL(12,2)
    )

    IF (@pTypeCustomer = 0) --INDIVIDUAL O CORPORATIVO
    BEGIN

        SELECT @TypeCustomer = IdCustomerType
        FROM Customer
        WHERE IdCustomer = @pId

        IF(@TypeCustomer = 1) --CORPORATIVO
        BEGIN

            INSERT INTO @INSURANCEEXC (
                 InsuranceRate
                ,InsuranceCharge
                ,InsuranceExempt
                ,CollectRate
            )
            SELECT DISTINCT
            ISNULL(RH.InsuranceRate,0)      [InsuranceRate],
            0                               [InsuranceCharge],
            ISNULL(RH.InsuranceExempt,0)    [InsuranceExempt],
            ISNULL(RH.CollectRate,0)        [CollectRate]
            FROM DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
                ON RH.RheId = RBC.RbcIdRate
            INNER JOIN DeliveryBackOffice.dbo.Customer C WITH(NOLOCK)
                ON RBC.RbcIdCustomer = C.IdCustomer
            WHERE C.IdCustomer = @pId 
            AND RH.CountryId = @pIdCountry 
            AND RH.RheRowStatus = 1
            AND RBC.RbcRowStatus = 1 
            --AND C.RowSatus = 1

        END
        ELSE IF(@TypeCustomer = 3) --INDIVIDUAL
        BEGIN

            INSERT INTO @INSURANCEEXC (
                 InsuranceRate
                ,InsuranceCharge
                ,InsuranceExempt
                ,CollectRate
            )
            SELECT DISTINCT
            IIF(ISNULL(RH.CollectRate,0) > 0, 0,ISNULL(RH.InsuranceRate,0)) [InsuranceRate],
            ISNULL(RH.InsuranceCharge,0)    [InsuranceCharge],
            ISNULL(RH.InsuranceExempt,0)    [InsuranceExempt],
            ISNULL(RH.CollectRate,0)        [CollectRate]
            FROM DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
                ON RH.RheId = RBC.RbcIdRate
            INNER JOIN DeliveryBackOffice.dbo.Customer C WITH(NOLOCK)
                ON RBC.RbcIdCustomer = C.IdCustomer
            WHERE C.IdCustomer = @pId 
            AND RH.CountryId = @pIdCountry 
            AND RH.RheRowStatus = 1
            AND RBC.RbcRowStatus = 1 
            --AND C.RowSatus = 1

            INSERT INTO @INSURANCEEXC (
                 InsuranceRate
                ,InsuranceCharge
                ,InsuranceExempt
                ,CollectRate
            )
            VALUES(
                1.5
               ,0.0
               ,5000
               ,4.00
            )

        END


    END;
    ELSE --CLIENTE CARTERA O EXC @pTypeCustomer = 1
    BEGIN

        INSERT INTO @INSURANCEEXC (
             InsuranceRate
            ,InsuranceCharge
            ,InsuranceExempt
            ,CollectRate
        )
        SELECT DISTINCT
        IIF(ISNULL(RH.CollectRate,0) > 0, 0,ISNULL(RH.InsuranceRate,0))      [InsuranceRate],
        ISNULL(RH.InsuranceCharge,0)    [InsuranceCharge],
        ISNULL(RH.InsuranceExempt,0)    [InsuranceExempt],
        ISNULL(RH.CollectRate,0)        [CollectRate]
        FROM DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
            ON RH.RheId = RBC.RbcIdRate
        INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
            ON RBC.RbcIdCustomer = VPC.CustomerID
        WHERE VPC.CodeOfReference = @pId
          AND RH.CountryId = @pIdCountry
          AND RH.RheRowStatus = 1 
          AND RBC.RbcRowStatus = 1

        INSERT INTO @INSURANCEEXC (
             InsuranceRate
            ,InsuranceCharge
            ,InsuranceExempt
            ,CollectRate
        )
        VALUES(
            1.5
           ,0.0
           ,5000
           ,4.00
        )

    END;

        SELECT
             InsuranceRate
            ,InsuranceCharge
            ,InsuranceExempt
            ,CollectRate
        FROM @INSURANCEEXC
END;