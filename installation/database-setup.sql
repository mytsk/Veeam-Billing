USE [master]
GO
/****** Object:  Database [db_Consumption]    Script Date: 2021-03-31 00:05:52 ******/
CREATE DATABASE [db_Consumption]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'db_Consumption', FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER158\MSSQL\Data\db_Consumption.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'db_Consumption_log', FILENAME = N'E:\MSSQL\Data\db_Consumption.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [db_Consumption] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [db_Consumption].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [db_Consumption] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [db_Consumption] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [db_Consumption] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [db_Consumption] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [db_Consumption] SET ARITHABORT OFF 
GO
ALTER DATABASE [db_Consumption] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [db_Consumption] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [db_Consumption] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [db_Consumption] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [db_Consumption] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [db_Consumption] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [db_Consumption] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [db_Consumption] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [db_Consumption] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [db_Consumption] SET  DISABLE_BROKER 
GO
ALTER DATABASE [db_Consumption] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [db_Consumption] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [db_Consumption] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [db_Consumption] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [db_Consumption] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [db_Consumption] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [db_Consumption] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [db_Consumption] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [db_Consumption] SET  MULTI_USER 
GO
ALTER DATABASE [db_Consumption] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [db_Consumption] SET DB_CHAINING OFF 
GO
ALTER DATABASE [db_Consumption] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [db_Consumption] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [db_Consumption] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [db_Consumption] SET QUERY_STORE = OFF
GO
/****** Object:  Table [dbo].[tbl_backups]    Script Date: 2021-03-31 00:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_backups](
	[backup_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NULL,
	[backupserver_id] [int] NULL,
	[backup_name] [varchar](75) NULL,
	[backup_size_org] [float] NULL,
	[backup_size_stored] [float] NULL,
	[Backup_type] [varchar](75) NULL,
	[backup_fetch_date] [datetime] NULL,
 CONSTRAINT [PK_tbl_backups] PRIMARY KEY CLUSTERED 
(
	[backup_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_backupserver]    Script Date: 2021-03-31 00:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_backupserver](
	[backupserver_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[license_id] [int] NOT NULL,
	[server_fqdn] [varchar](75) NULL,
	[server_username] [varchar](75) NULL,
	[server_added_date] [datetime] NULL,
	[is_active] [bit] NULL,
	[server_major_version] [varchar](20) NULL,
	[server_version] [varchar](50) NULL,
	[server_license_edition] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_customer]    Script Date: 2021-03-31 00:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_customer](
	[customer_id] [int] IDENTITY(1000,1) NOT NULL,
	[vc_customer_id] [int] NULL,
	[customer_name] [varchar](75) NULL,
	[customer_tag] [varchar](50) NULL,
	[customer_address] [varchar](75) NULL,
	[customer_added_by] [varchar](75) NULL,
	[customer_added_date] [datetime] NULL,
 CONSTRAINT [PK__Customer__6E186BCC82FAEECF] PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_job]    Script Date: 2021-03-31 00:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_job](
	[job_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[backupserver_id] [int] NULL,
	[job_name] [varchar](75) NULL,
	[job_size_org] [float] NULL,
	[job_size_stored] [float] NULL,
	[job_type] [varchar](75) NULL,
	[job_fetch_session] [varchar](40) NULL,
	[job_fetch_date] [varchar](25) NULL,
 CONSTRAINT [PK__tbl_jobd__BA35AF521D9477BF] PRIMARY KEY CLUSTERED 
(
	[job_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_jobStatistics]    Script Date: 2021-03-31 00:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_jobStatistics](
	[jobStatistics_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NULL,
	[backupserver_id] [int] NULL,
	[stat_jobId] [varchar](50) NULL,
	[stat_jobName] [varchar](50) NULL,
	[stat_job_type] [varchar](50) NULL,
	[stat_jobSourceType] [varchar](20) NULL,
	[stat_jobIsScheduleEnabled] [varchar](20) NULL,
	[stat_jobDescription] [varchar](50) NULL,
	[stat_jobRunManually] [varchar](10) NULL,
	[stat_jobCreationTime] [datetime] NULL,
	[stat_jobEndTime] [datetime] NULL,
	[stat_jobIsWorking] [varchar](50) NULL,
	[stat_jobIsCompleted] [varchar](20) NULL,
	[stat_jobBaseProgress] [int] NULL,
	[stat_jobModifiedBy] [varchar](50) NULL,
	[stat_jobEncryptionEnabled] [varchar](10) NULL,
	[stat_jobConfiguredSizeGB] [float] NULL,
	[stat_jobProcessedUsedSizeGB] [float] NULL,
	[stat_jobReadSizeGB] [float] NULL,
	[stat_jobTransferredSizeGB] [float] NULL,
	[stat_jobBottleneck] [varchar](20) NULL,
	[stat_jobBottleneckSourceWan] [int] NULL,
	[stat_jobBottleneckSourceProxy] [int] NULL,
	[stat_jobBottleneckSourceNetwork] [int] NULL,
	[stat_jobBottleneckSourceStorage] [int] NULL,
	[stat_jobBottleneckTargetWan] [int] NULL,
	[stat_jobBottleneckTargetProxy] [int] NULL,
	[stat_jobBottleneckTargetNetwork] [int] NULL,
	[stat_jobBottleneckTargetStorage] [int] NULL,
	[stat_date_fetched] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_license]    Script Date: 2021-03-31 00:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_license](
	[license_id] [int] IDENTITY(1,1) NOT NULL,
	[license_name] [varchar](75) NULL,
	[license_type] [varchar](50) NULL,
	[license_pts] [float] NOT NULL,
	[license_sku] [varchar](75) NULL,
	[license_added_date] [datetime] NULL,
 CONSTRAINT [PK__tbl_lice__F04D3748E4140BDB] PRIMARY KEY CLUSTERED 
(
	[license_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_licenseUsage]    Script Date: 2021-03-31 00:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_licenseUsage](
	[licenseUsage_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NULL,
	[backupserver_id] [int] NULL,
	[licenseUsage_fqdn] [varchar](50) NULL,
	[licenseUsage_Type] [varchar](20) NULL,
	[licenseUsage_Count] [int] NULL,
	[licenseUsage_Multiplier] [float] NULL,
	[licenseUsage_UsedInstancesNumber] [float] NULL,
	[licenseUsage_date_fetched] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_licenseUsageOld]    Script Date: 2021-03-31 00:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_licenseUsageOld](
	[licenseUsage_id] [int] IDENTITY(1,1) NOT NULL,
	[licenseUsage_fqdn] [varchar](50) NULL,
	[licenseUsage_Type] [varchar](20) NULL,
	[licenseUsage_Count] [int] NULL,
	[licenseUsage_Multiplier] [float] NULL,
	[licenseUsage_UsedInstancesNumber] [float] NULL,
	[licenseUsage_server_id] [int] NULL,
	[licenseUsage_fetched_session] [varchar](50) NULL,
	[licenseUsage_added_date] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_sessionStatistics]    Script Date: 2021-03-31 00:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_sessionStatistics](
	[sessionstats_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NULL,
	[backupserver_id] [int] NULL,
	[stat_obj_name] [varchar](50) NULL,
	[stat_backup_job] [varchar](50) NULL,
	[stat_job_type] [varchar](50) NULL,
	[stat_status] [varchar](10) NULL,
	[stat_taskAlgorithm] [varchar](20) NULL,
	[stat_bottleneck] [varchar](20) NULL,
	[stat_bottleneckSourceWan] [int] NULL,
	[stat_bottleneckSourceProxy] [int] NULL,
	[stat_bottleneckSourceNetwork] [int] NULL,
	[stat_bottleneckSourceStorage] [int] NULL,
	[stat_bottleneckTargetWan] [int] NULL,
	[stat_bottleneckTargetProxy] [int] NULL,
	[stat_bottleneckTargetNetwork] [int] NULL,
	[stat_bottleneckTargetStorage] [int] NULL,
	[stat_startTime] [datetime] NULL,
	[stat_stopTime] [datetime] NULL,
	[stat_duration] [varchar](50) NULL,
	[stat_processedSizeGB] [float] NULL,
	[stat_usedGB] [float] NULL,
	[stat_processedUsedSizeGB] [float] NULL,
	[stat_readSizeGB] [float] NULL,
	[stat_jobSessId] [varchar](50) NULL,
	[stat_job_id] [varchar](50) NULL,
	[stat_backupserver] [varchar](50) NULL,
	[stat_date_fetched] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_stats]    Script Date: 2021-03-31 00:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_stats](
	[session_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[backupserver_id] [int] NULL,
	[stats_obj_name] [varchar](50) NULL,
	[stats_backup_job] [varchar](50) NULL,
	[stats_transfered_gb] [float] NULL,
	[stats_backup_sessions] [int] NULL,
	[stats_restorepoints] [int] NULL,
	[stats_period] [varchar](10) NULL,
	[stats_date_fetched] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_backups] ADD  CONSTRAINT [DF_tbl_backups_backup_fetch_date]  DEFAULT (getdate()) FOR [backup_fetch_date]
GO
ALTER TABLE [dbo].[tbl_backupserver] ADD  CONSTRAINT [DF_tbl_backupserver_server_added_date]  DEFAULT (getdate()) FOR [server_added_date]
GO
ALTER TABLE [dbo].[tbl_customer] ADD  CONSTRAINT [DF_tbl_customers_customer_added_datetime]  DEFAULT (getdate()) FOR [customer_added_date]
GO
ALTER TABLE [dbo].[tbl_job] ADD  CONSTRAINT [DF_tbl_jobdata_job_fetch_date]  DEFAULT (getdate()) FOR [job_fetch_date]
GO
ALTER TABLE [dbo].[tbl_jobStatistics] ADD  CONSTRAINT [DF_tbl_jobStatistics_stat_date_fetched]  DEFAULT (getdate()) FOR [stat_date_fetched]
GO
ALTER TABLE [dbo].[tbl_license] ADD  CONSTRAINT [DF_tbl_licenses_license_added_date]  DEFAULT (getdate()) FOR [license_added_date]
GO
ALTER TABLE [dbo].[tbl_licenseUsage] ADD  CONSTRAINT [DF_tbl_licenseUsage2_licenseUsage_added_date]  DEFAULT (getdate()) FOR [licenseUsage_date_fetched]
GO
ALTER TABLE [dbo].[tbl_sessionStatistics] ADD  CONSTRAINT [DF_tbl_sessionstats_stat_date_fetched]  DEFAULT (getdate()) FOR [stat_date_fetched]
GO
ALTER TABLE [dbo].[tbl_stats] ADD  CONSTRAINT [DF_Table_1_object_datefetched]  DEFAULT (getdate()) FOR [stats_date_fetched]
GO
/****** Object:  StoredProcedure [dbo].[StatisticsPurgeDuplicates]    Script Date: 2021-03-31 00:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[StatisticsPurgeDuplicates]  
AS

		WITH cte AS (
    SELECT 
        sessionstats_id,
        stat_job_id, 
        ROW_NUMBER() OVER (
            PARTITION BY 
                stat_job_id 
            ORDER BY 
                stat_job_id
        ) row_num
     FROM 
        tbl_sessionStatistics
)
DELETE FROM cte
WHERE row_num > 1;
GO
/****** Object:  StoredProcedure [dbo].[StatisticsUniqueValues]    Script Date: 2021-03-31 00:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[StatisticsUniqueValues]  
AS

	SELECT * FROM (
		SELECT *, row_number() OVER (partition BY stat_job_id ORDER BY stat_obj_name) as rn FROM [dbo].[tbl_sessionStatistics]
	) a 
	WHERE rn = 1
	ORDER BY sessionstats_id
GO
USE [master]
GO
ALTER DATABASE [db_Consumption] SET  READ_WRITE 
GO
