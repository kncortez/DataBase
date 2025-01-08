--PASO 1: Deshabilitar la llamda de TblAddressList en el SP supportSetVisitPointByClientPortfolio.
--PASO 2: Deshabilitar la llamda de TblAddressList en el SP SetVisitPointByClientPortfolio.

-- eliminamos el tipo si existe
DROP TYPE dbo.TblAddressList;

--lo volvemos a crear con la nueva columna de IdCityPlace

CREATE TYPE [dbo].[TblAddressList] AS TABLE (
    [RowNumber]                     INT            NOT NULL,
    [IdAddress]                     INT            NULL,
    [IdTownship]                    INT            NULL,
    [IdAccount]                     INT            NULL,
    [IdCountry]                     NVARCHAR (5)   NULL,
    [FullName]                      NVARCHAR (150) NULL,
    [Address1]                      NVARCHAR (600) NULL,
    [Address2]                      NVARCHAR (600) NULL,
    [NirPhone]                      NVARCHAR (10)  NULL,
    [Phone]                         NVARCHAR (20)  NULL,
    [AdditionalInstructions]        NVARCHAR (200) NULL,
    [IdCityPlace]                   INT            NULL,
    [Status]                        INT            NULL,
    [Token]                         NVARCHAR (200) NULL,
    [IdVisitPointByClientPortfolio] INT            NULL,
    [IdSettlement]                  INT            NULL,
    [IdDeliveryOption]              INT            NULL);

--PASO 5: Habilitar la llamda de TblAddressList en el SP supportSetVisitPointByClientPortfolio.
--PASO 6: Habilitar la llamda de TblAddressList en el SP SetVisitPointByClientPortfolio.