ALTER TABLE dbo.StatusOrdera 
    ADD StatusMessage NVARCHAR(500) NULL

	EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mensaje de estado para consumo Contact Center', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'StatusMessage';