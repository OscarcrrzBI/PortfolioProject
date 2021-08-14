--*************************************************************************--
-- Title: Module08 DW Destination Database
-- Desc:This file will drop and create a DW database for module 08's assignment. 
-- Change Log: When,Who,What
-- 2020-01-01,RRoot,Created File
-- 6/7/21,Oscar Cruz,Completed File
--*************************************************************************--

-- Create Database --
--*************************************************************************--

Use Master;
Go
If Exists(Select name from master.dbo.sysdatabases Where Name = 'DWIndependentBookSellers')
Begin
	Use [Master];
	Alter Database [DWIndependentBookSellers] Set Single_User With Rollback Immediate;
	Drop Database [DWIndependentBookSellers];
End;
Go

Create Database [DWIndependentBookSellers]; 
Go

Use [DWIndependentBookSellers];
Go

--DimAuthors Table
Go
Create Table [DWIndependentBookSellers].[dbo].[DimAuthors](
	 [AuthorKey] int IDENTITY		NOT NULL
	,[AuthorID] nvarchar(100)		NOT NULL
	,[AuthorName] nvarchar(100)		NOT NULL
	 CONSTRAINT PK_DimAuthors PRIMARY KEY (AuthorKey)
	);
Go

--DimTitles table
Go
Create Table [DWIndependentBookSellers].[dbo].[DimTitles](
	 [TitleKey] int IDENTITY		NOT NULL
	,[TitleID] nvarchar(100)		NOT NULL
	,[TitleName] nvarchar(100)		NOT NULL
	,[TitleType] nvarchar(100)		NOT NULL
	,[TitlePrice] decimal(18,4)		
	 CONSTRAINT PK_DimTitles PRIMARY KEY (TitleKey)
	);
Go

--DimStores Table
Create Table [DWIndependentBookSellers].[dbo].[DimStores](
	 [StoreKey] int IDENTITY		NOT NULL
	,[StoreID] int					NOT NULL
	,[StoreName] nvarchar(100)		NOT NULL
	,[StoreState] nvarchar(100)		NOT NULL
	 CONSTRAINT PK_DimStores PRIMARY KEY (StoreKey)
	);
Go

-- DimDates Table
Create Table [DWIndependentBookSellers].[dbo].[DimDates](
	 [DateKey] int 					NOT NULL
	,[FullDate] date				NOT NULL
	,[USADateName] nvarchar(100)	NOT NULL
	,[MonthKey] int					NOT NULL
	,[MonthName] nvarchar(100)		NOT NULL
	,[QuarterKey] int				NOT NULL
	,[QuarterName] nvarchar(100)	NOT NULL
	,[YearKey] int					NOT NULL
	,[YearName] nvarchar(100)		NOT NULL
	 CONSTRAINT PK_DimDates PRIMARY KEY (DateKey)
	); -- Note: this table will be filled in the ETL script
GO

-- Create Fact Tables --
--*************************************************************************--
--FactTitlesAuthors Table
Go
Create Table [DWIndependentBookSellers].[dbo].[FactTitlesAuthors](
	 [TitlesAuthorsID] int IDENTITY	NOT NULL
	,[AuthorKey] int				NOT NULL
	,[TitleKey] int					NOT NULL
	,[AuthorOrder] int				NOT NULL
	CONSTRAINT PK_FactTitlesAuthors PRIMARY KEY (TitlesAuthorsID, AuthorKey, TitleKey)
	);
GO

--FactSales Table
Create Table [DWIndependentBookSellers].[dbo].[FactSales](
	 [SalesKey] int IDENTITY		NOT NULL
	,[OrderNumber] nvarchar(100)	NOT NULL
	,[DateKey] int					NOT NULL
	,[StoreKey] int					NOT NULL
	,[TitleKey] int					NOT NULL
	,[SalesQuantity] int			NOT NULL
	,[SalesPrice] decimal(18,4)		NOT NULL
	CONSTRAINT PK_FactSales PRIMARY KEY (SalesKey, DateKey, StoreKey, TitleKey)
	);
GO

-- Add Constraints --
--*************************************************************************--

ALTER TABLE [DWIndependentBookSellers].[dbo].[FactTitlesAuthors] ADD CONSTRAINT FK_FactTitlesAuthors_DimAuthors
  FOREIGN KEY (AuthorKey) REFERENCES DimAuthors(AuthorKey)

ALTER TABLE [DWIndependentBookSellers].[dbo].[FactTitlesAuthors] ADD CONSTRAINT FK_FactTitlesAuthors_DimTitles
  FOREIGN KEY (TitleKey) REFERENCES DimTitles(TitleKey)

ALTER TABLE [DWIndependentBookSellers].[dbo].[FactSales] ADD CONSTRAINT FK_FactSales_DimDates
	FOREIGN KEY (DateKey) REFERENCES DimDates(DateKey)

ALTER TABLE [DWIndependentBookSellers].[dbo].[FactSales] ADD CONSTRAINT FK_FactSales_DimStores
	FOREIGN KEY (StoreKey) REFERENCES DimStores(StoreKey)

ALTER TABLE [DWIndependentBookSellers].[dbo].[FactSales] ADD CONSTRAINT FK_FactSales_DimTitles
	FOREIGN KEY (TitleKey) REFERENCES DimTitles(TitleKey)



Select  
  SourceObjectName = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
, DataType = DATA_TYPE + IIF(CHARACTER_MAXIMUM_LENGTH is Null, '' , '(' + Cast(CHARACTER_MAXIMUM_LENGTH as varchar(10)) + ')')
, Nullable = IS_NULLABLE
From INFORMATION_SCHEMA.COLUMNS
go

Select 'Database Created'
Select Name, xType, CrDate from SysObjects 
Where xType in ('u', 'PK', 'F')
Order By xType desc, Name