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
    [Status]                        INT            NULL,
    [Token]                         NVARCHAR (200) NULL,
    [IdVisitPointByClientPortfolio] INT            NULL,
    [IdSettlement]                  INT            NULL,
    [IdCityPlace]                   INT            NULL,
    [IdDeliveryOption]              INT            NULL);



