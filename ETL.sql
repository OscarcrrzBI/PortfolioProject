--*************************************************************************--
-- Title: Module08 DW ETL Process
-- Desc:This file will drop and create an ETL process for module 08's assignment. 
-- Change Log: When,Who,What
-- 2020-01-01,RRoot,Created File
-- 06/07/2021,Oscar Cruz,Completed File
--*************************************************************************--
Use DWIndependentBookSellers;
go

-- Drop Sprocs if needed --
Begin Try Drop Proc pETLDropFks; End Try Begin Catch End Catch
Begin Try Drop Proc pETLTruncateTables; End Try Begin Catch End Catch
Begin Try Drop Proc pETLDimAuthors; End Try Begin Catch End Catch
Begin Try Drop Proc pETLDimTitles; End Try Begin Catch End Catch
Begin Try Drop Proc pETLDimStores; End Try Begin Catch End Catch
Begin Try Drop Proc pETLDimDates; End Try Begin Catch End Catch
Begin Try Drop Proc pETLFactTitlesAuthors; End Try Begin Catch End Catch
Begin Try Drop Proc pETLFactSales; End Try Begin Catch End Catch
Begin Try Drop Proc pETLReplaceFks; End Try Begin Catch End Catch
go

-- 1) Drop Foreign Key Constraints and Clear tables
--*************************************************************************--
go
Create Proc pETLDropFks
As 
Begin 
	Begin Try
		ALTER TABLE [DWIndependentBookSellers].[dbo].[FactTitlesAuthors] DROP CONSTRAINT FK_FactTitlesAuthors_DimTitles
		ALTER TABLE [DWIndependentBookSellers].[dbo].[FactTitlesAuthors] DROP CONSTRAINT FK_FactTitlesAuthors_DimAuthors
		ALTER TABLE [DWIndependentBookSellers].[dbo].[FactSales] DROP CONSTRAINT FK_FactSales_DimDates
		ALTER TABLE [DWIndependentBookSellers].[dbo].[FactSales] DROP CONSTRAINT FK_FactSales_DimStores
		ALTER TABLE [DWIndependentBookSellers].[dbo].[FactSales] DROP CONSTRAINT FK_FactSales_DimTitles

	End Try
	Begin Catch
		Print Error_Message()
	End Catch
End

Go
Create Proc pETLTruncateTables
As 
Begin 
	Begin Try
		Truncate Table [DWIndependentBookSellers].[dbo].[DimTitles]
		Truncate Table [DWIndependentBookSellers].[dbo].[DimAuthors]
		Truncate Table [DWIndependentBookSellers].[dbo].[DimStores]
		Truncate Table [DWIndependentBookSellers].[dbo].[FactTitlesAuthors]
		Truncate Table [DWIndependentBookSellers].[dbo].[FactSales]
	End Try
	Begin Catch
		Print Error_Message()
	End Catch
End
Go

-- 2) Fill Tables
--*************************************************************************--
-- DimAuthors Table
Go
Create Proc pETLDimAuthors
As
Begin
	Begin Try
		Insert Into [DWIndependentBookSellers].[dbo].[DimAuthors](
			 [AuthorID]
			,[AuthorName]
		)
		Select
			 [AuthorID] = Cast([au_id] as varchar(100))
			,[AuthorName] = Cast(([au_fname] + ' ' + [au_lname]) as varchar(100))
		From [IndependentBookSellers].[dbo].[Authors];
	End Try
	Begin Catch
		Print Error_Message()
	End Catch
End
Go

-- DimTitles Table
Go
Create Proc pETLDimTitles
As
Begin
	Begin Try
		Insert Into [DWIndependentBookSellers].[dbo].[DimTitles](
			 [TitleID]
			,[TitleName]
			,[TitleType]
			,[TitlePrice]
		)
		Select
			 [TitleID] = Cast([title_id] as varchar(100))
			,[TitleName] = Cast([title] as varchar(100))
			,[TitleType] = Cast([type] as varchar(100))
			,[TitlePrice] = Cast([price] as decimal(18,4))
		From [IndependentBookSellers].[dbo].[Titles];
	End Try
	Begin Catch
		Print Error_Message()
	End Catch
End
Go

-- DimStores Table
Go
Create Proc pETLDimStores
As
Begin
	Begin Try
		Insert Into [DWIndependentBookSellers].[dbo].[DimStores](
			 [StoreID]
			,[StoreName]
			,[StoreState]
		)
		Select
			 [StoreID] = Cast([stor_id] as int)
			,[StoreName] = Cast([stor_name] as varchar(100))
			,[StoreState] = Cast([state] as varchar(100))
		From [IndependentBookSellers].[dbo].[Stores];
	End Try
	Begin Catch
		Print Error_Message()
	End Catch
End
Go

--DimDates Table
Go
Create Proc pETLDimDates
As 
Begin 
 Begin Try
    Set NoCount On
	-- Create variables to hold the start and end date
	Declare @StartDate datetime = '01/01/1992'
	Declare @EndDate datetime = '12/31/1994' 

	-- Use a while loop to add dates to the table
	Declare @DateInProcess datetime
	Set @DateInProcess = @StartDate

	While @DateInProcess <= @EndDate
	 Begin
	   -- Add a row into the date dimensiOn table for this date
	   Insert Into DimDates 
	   ( [DateKey], [FullDate], [USADateName], [MonthKey], [MonthName], [QuarterKey], [QuarterName], [YearKey], [YearName] )
	   Values ( 
	  	Cast(Convert(nvarchar(50), @DateInProcess , 112) as int) -- [DateKey]
	    , @DateInProcess -- [FullDate]
	    , DateName( weekday, @DateInProcess ) + ', ' + Convert(nvarchar(50), @DateInProcess , 110) -- [USADateName]  
	    , Left(Cast(Convert(nvarchar(50), @DateInProcess , 112) as int), 6) -- [MonthKey]   
	    , DateName( MONTH, @DateInProcess ) + ', ' + Cast( Year(@DateInProcess ) as nVarchar(50) ) -- [MonthName]
	    ,  Cast(Cast(YEAR(@DateInProcess) as nvarchar(50))  + '0' + DateName( QUARTER,  @DateInProcess) as int) -- [QuarterKey]
	    , 'Q' + DateName( QUARTER, @DateInProcess ) + ', ' + Cast( Year(@DateInProcess) as nVarchar(50) ) -- [QuarterName] 
	    , Year( @DateInProcess ) -- [YearKey]
	    , Cast( Year(@DateInProcess ) as nVarchar(50) ) -- [YearName] 
	    )  
	   -- Add a day and loop again
	   Set @DateInProcess = DateAdd(d, 1, @DateInProcess)
	 End

	-- 2e) Add additional lookup values to DimDates
	Insert Into DimDates 
	  ( [DateKey]
	  , [FullDate]
	  , [USADateName]
	  , [MonthKey]
	  , [MonthName]
	  , [QuarterKey]
	  , [QuarterName]
	  , [YearKey]
	  , [YearName] )
	  Select 
		[DateKey] = -1
	  , [FullDate] = '19000101'
	  , [DateName] = Cast('Unknown Day' as nVarchar(50) )
	  , [MonthKey] = -1
	  , [MonthName] = Cast('Unknown Month' as nVarchar(50) )
	  , [QuarterKey] =  -1
	  , [QuarterName] = Cast('Unknown Quarter' as nVarchar(50) )
	  , [YearKey] = -1
	  , [YearName] = Cast('Unknown Year' as nVarchar(50) )
	  Union
	  Select 
		[DateKey] = -2
	  , [FullDate] = '19000102'
	  , [DateName] = Cast('Corrupt Day' as nVarchar(50) )
	  , [MonthKey] = -2
	  , [MonthName] = Cast('Corrupt Month' as nVarchar(50) )
	  , [QuarterKey] =  -2
	  , [QuarterName] = Cast('Corrupt Quarter' as nVarchar(50) )
	  , [YearKey] = -2
	  , [YearName] = Cast('Corrupt Year' as nVarchar(50) )
  End Try
  Begin Catch
    Print Error_Message()
  End Catch
  Set NoCount Off
End
Go

-- FactTitlesAuthors table
Go
Create Proc pETLFactTitlesAuthors
As 
Begin 
	Begin Try
		Insert Into [DWIndependentBookSellers].[dbo].[FactTitlesAuthors](
			 [AuthorKey]
			,[TitleKey]
			,[AuthorOrder]
		)
		Select			
			 [AuthorKey] = AuthorKey
			,[TitleKey] = TitleKey
			,[AuthorOrder] = [au_ord] 
		From [IndependentBookSellers].[dbo].[TitleAuthors] as TA
			Join DimAuthors as DA
			  On TA.au_id = DA.AuthorID
			Join DimTitles as DT
			  On TA.title_id = DT.TitleID
	End Try
	Begin Catch
		Print Error_Message()
	End Catch
End
Go

Go
Create Proc pETLFactSales
As 
Begin 
	Begin Try
		Insert Into [DWIndependentBookSellers].[dbo].[FactSales](
			 [OrderNumber]
			,[DateKey]
			,[StoreKey]
			,[TitleKey]
			,[SalesQuantity]
			,[SalesPrice]
		)
		Select			
			 [OrderNumber] = Cast(SD.ord_num as varchar(100))
			,[Datekey] = DateKey
			,[StoreKey] = StoreKey
			,[TitleKey] = TitleKey
			,[SalesQuantity] = Cast(qty as varchar(100))
			,[SalesPrice] = Cast(price as decimal(18,4))
		From [IndependentBookSellers].[dbo].[SalesDetails] as SD
			Join [IndependentBookSellers].[dbo].[SalesHeader] as SH
			  On SD.ord_num = SH.ord_num
			Join DimTitles as DT
			  On SD.title_id = DT.TitleID
			Join DimDates as DD
			 On SH.ord_date = DD.FullDate
			Join DimStores as DS
			  On SH.stor_id = DS.StoreID
	End Try
	Begin Catch
		Print Error_Message()
	End Catch
End
Go

Go
Create Proc pETLReplaceFks
As 
Begin 
	Begin Try
		ALTER TABLE [DWIndependentBookSellers].[dbo].[FactTitlesAuthors] ADD CONSTRAINT FK_FactTitlesAuthors_DimAuthors
		FOREIGN KEY (AuthorKey) REFERENCES DimAuthors(AuthorKey)

		ALTER TABLE [DWIndependentBookSellers].[dbo].[FactTitlesAuthors] ADD CONSTRAINT FK_FactTitlesAuthors_DimTitles
		FOREIGN KEY (TitleKey) REFERENCES DimTitles(TitleKey)

		ALTER TABLE [DWIndependentBookSellers].[dbo].[FactSales] ADD CONSTRAINT FK_FactSales_DimDates
		FOREIGN KEY (DateKey) REFERENCES DimDates(DateKey)

		ALTER TABLE [DWIndependentBookSellers].[dbo].[FactSales] ADD CONSTRAINT FK_FactSales_DimStores
		FOREIGN KEY (StoreKey) REFERENCES DimStores(StoreKey)

		ALTER TABLE [DWIndependentBookSellers].[dbo].[FactSales] Add CONSTRAINT FK_FactSales_DimTitles
		FOREIGN KEY (TitleKey) REFERENCES DimTitles(TitleKey)


	End Try
	Begin Catch
		Print Error_Message()
	End Catch
End
Go

GO

Exec pETLDropFks;
Exec pETLTruncateTables;
Exec pETLDimAuthors;
Exec pETLDimTitles;
Exec pETLDimStores;
Exec pETLDimDates;
Exec pETLFactTitlesAuthors;
Exec pETLFactSales;
Exec pETLReplaceFks;


Select * From [dbo].[DimAuthors];
Select * From [dbo].[DimTitles];
Select * From [dbo].[DimStores];
Select * From [dbo].[DimDates];
Select * From [dbo].[FactTitlesAuthors];
Select * From [dbo].[FactSales];



