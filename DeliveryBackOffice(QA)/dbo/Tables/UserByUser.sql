CREATE TABLE [dbo].[UserByUser] (
    [UbuIdUserAdmin] BIGINT NOT NULL,
    [UbuIdUserChild] BIGINT NOT NULL,
    [UbuRowStatus]   BIT    NOT NULL,
    PRIMARY KEY CLUSTERED ([UbuIdUserAdmin] ASC, [UbuIdUserChild] ASC),
    CONSTRAINT [FKUserAdmin] FOREIGN KEY ([UbuIdUserAdmin]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser]),
    CONSTRAINT [FKUserChild] FOREIGN KEY ([UbuIdUserChild]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);

