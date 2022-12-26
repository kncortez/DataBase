CREATE TABLE [dbo].[Account] (
    [AccIdAccount]     BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccName]          VARCHAR (100)  NOT NULL,
    [AccIdTypeAccount] INT            NOT NULL,
    [AccRowStatus]     BIT            NOT NULL,
    [AccTokenCreated]  VARCHAR (50)   NOT NULL,
    [AccDateCreated]   DATETIME       NOT NULL,
    [AccTokenUpdated]  VARCHAR (50)   NULL,
    [AccDateUpdated]   DATETIME       NULL,
    [IdCustomer]       INT            NULL,
    [AccConfirm]       CHAR (1)       NULL,
    [ImageProfile]     NVARCHAR (300) NULL,
    [StarRating]       INT            NULL,
    PRIMARY KEY CLUSTERED ([AccIdAccount] ASC),
    CONSTRAINT [FKAccountType] FOREIGN KEY ([AccIdTypeAccount]) REFERENCES [dbo].[CatTypeAccount] ([TacIdTypeAccount]),
    CONSTRAINT [FKIdCustumer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer])
);






GO
CREATE NONCLUSTERED INDEX [IDX_IdCustomer]
    ON [dbo].[Account]([IdCustomer] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo que representa el numero de estrellas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'StarRating';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar imagen del perfil del usuario.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'ImageProfile';

